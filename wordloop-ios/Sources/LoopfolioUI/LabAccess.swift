// Why: the lab is an experiment, not a shipping surface. Debug builds show it in Settings;
// Release compiles the entry out so it cannot leak into production navigation.

enum LabAccess {
    static var isEnabled: Bool {
        #if DEBUG
        true
        #else
        false
        #endif
    }
}
