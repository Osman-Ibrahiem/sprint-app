/// Reviewer-only tools (the user switcher and the settings inspector) are on
/// by default so the defense build can show them. Build with
/// `--dart-define=HIDE_DEMO_TOOLS=true` to remove them (FR-031).
const bool demoToolsEnabled = !bool.fromEnvironment('HIDE_DEMO_TOOLS');
