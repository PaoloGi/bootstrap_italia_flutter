package com.example.bootstrap_italia_example;

import android.content.Context;
import android.content.Intent;
import android.view.accessibility.AccessibilityNodeInfo;

import androidx.test.ext.junit.runners.AndroidJUnit4;
import androidx.test.platform.app.InstrumentationRegistry;
import androidx.test.uiautomator.UiDevice;

import org.junit.Test;
import org.junit.runner.RunWith;

/**
 * Dumps what Android really exposes, including the fields `uiautomator dump`
 * omits.
 *
 * <p>The XML dump reports only: bounds, checkable, checked, class, clickable,
 * content-desc, enabled, focusable, focused, index, long-clickable, package,
 * password, resource-id, scrollable, selected, text. It has no attribute for
 * <b>hintText</b> or <b>stateDescription</b>.
 *
 * <p>That gap produced a false positive: an editable field with an empty
 * content-desc was reported as having no accessible name, when Android delivers
 * an editable field's name through {@code setHintText()}. It also made the
 * accordion's expansion state unreadable, since that travels in
 * {@code stateDescription}.
 *
 * <p>Run against whatever screen the app is already showing:
 * <pre>
 *   adb shell am instrument -w -e class \
 *     com.example.bootstrap_italia_example.AccessibilityDumpTest \
 *     com.example.bootstrap_italia_example.test/androidx.test.runner.AndroidJUnitRunner
 * </pre>
 */
@RunWith(AndroidJUnit4.class)
public class AccessibilityDumpTest {

    @Test
    public void dumpAccessibilityTree() throws Exception {
        UiDevice device = UiDevice.getInstance(
                InstrumentationRegistry.getInstrumentation());

        // Instrumentation force-stops the app under test, so whatever page was
        // open before is gone. The test navigates itself: pass `-e page Input`.
        //
        // Navigation uses ACCESSIBILITY ACTIONS, not injected touches. This ROM
        // refuses UiAutomator's injection with "Injecting to another
        // application requires INJECT_EVENTS permission"; ACTION_CLICK and
        // ACTION_SCROLL_FORWARD go through the accessibility channel and need
        // no such permission — and they are what a screen reader itself uses,
        // which makes them the more faithful driver in any case.
        // Instrumentation force-stopped the app, and the device may surface
        // something else entirely; launch the target explicitly.
        Context ctx = InstrumentationRegistry.getInstrumentation().getTargetContext();
        Intent launch = ctx.getPackageManager()
                .getLaunchIntentForPackage("com.example.bootstrap_italia_example");
        launch.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        ctx.startActivity(launch);
        Thread.sleep(5000);

        String page = InstrumentationRegistry.getArguments().getString("page");
        if (page != null) {
            for (int scroll = 0; scroll < 8; scroll++) {
                AccessibilityNodeInfo r = InstrumentationRegistry.getInstrumentation()
                        .getUiAutomation().getRootInActiveWindow();
                AccessibilityNodeInfo row = findByDesc(r, page);
                if (row != null) {
                    row.performAction(AccessibilityNodeInfo.ACTION_CLICK);
                    Thread.sleep(2500);
                    break;
                }
                AccessibilityNodeInfo sc = findScrollable(r);
                if (sc == null) break;
                sc.performAction(AccessibilityNodeInfo.ACTION_SCROLL_FORWARD);
                Thread.sleep(900);
            }
        }

        AccessibilityNodeInfo root = InstrumentationRegistry.getInstrumentation()
                .getUiAutomation().getRootInActiveWindow();
        System.out.println("A11YDUMP begin package=" + device.getCurrentPackageName());
        walk(root, 0);
        System.out.println("A11YDUMP end");
    }

    private void walk(AccessibilityNodeInfo n, int depth) {
        if (n == null) return;

        CharSequence desc = n.getContentDescription();
        CharSequence text = n.getText();
        CharSequence hint = null;
        CharSequence state = null;
        try { hint = n.getHintText(); } catch (Throwable ignored) { }
        try { state = n.getStateDescription(); } catch (Throwable ignored) { }

        boolean interesting = desc != null || text != null || hint != null
                || state != null || n.isCheckable() || n.isClickable();
        if (interesting) {
            StringBuilder actions = new StringBuilder();
            for (AccessibilityNodeInfo.AccessibilityAction a : n.getActionList()) {
                int id = a.getId();
                if (id == AccessibilityNodeInfo.ACTION_EXPAND) actions.append("EXPAND ");
                if (id == AccessibilityNodeInfo.ACTION_COLLAPSE) actions.append("COLLAPSE ");
            }
            System.out.println("A11YDUMP "
                    + "cls=" + shortName(n.getClassName())
                    + " desc=" + q(desc)
                    + " text=" + q(text)
                    + " hint=" + q(hint)
                    + " state=" + q(state)
                    + " checkable=" + n.isCheckable()
                    + " checked=" + n.isChecked()
                    + " actions=" + actions.toString().trim());
        }
        for (int i = 0; i < n.getChildCount(); i++) walk(n.getChild(i), depth + 1);
    }

    private AccessibilityNodeInfo findByDesc(AccessibilityNodeInfo n, String want) {
        if (n == null) return null;
        CharSequence d = n.getContentDescription();
        if (d != null && want.contentEquals(d) && n.isClickable()) return n;
        for (int i = 0; i < n.getChildCount(); i++) {
            AccessibilityNodeInfo hit = findByDesc(n.getChild(i), want);
            if (hit != null) return hit;
        }
        return null;
    }

    private AccessibilityNodeInfo findScrollable(AccessibilityNodeInfo n) {
        if (n == null) return null;
        if (n.isScrollable()) return n;
        for (int i = 0; i < n.getChildCount(); i++) {
            AccessibilityNodeInfo hit = findScrollable(n.getChild(i));
            if (hit != null) return hit;
        }
        return null;
    }

    private String shortName(CharSequence cls) {
        if (cls == null) return "?";
        String s = cls.toString();
        int i = s.lastIndexOf('.');
        return i < 0 ? s : s.substring(i + 1);
    }

    private String q(CharSequence c) {
        return c == null ? "<null>" : "\"" + c.toString().replace("\n", " ") + "\"";
    }
}
