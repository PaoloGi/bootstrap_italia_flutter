/// Text scale on everything that is not the web: whatever the platform says.
///
/// The web build reads `?textScale=` from the URL because a browser gives the
/// driver no other way to set Flutter's scaler. On a device there IS another
/// way — the OS accessibility setting — and the integration test sets it
/// through `MediaQuery` directly, so this returns the neutral value.
double urlTextScale() => 1.0;
