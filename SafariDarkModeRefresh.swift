import AppKit

final class SafariDarkModeRefreshService {
    private var wasDark = SafariDarkModeRefreshService.isDark()
    private var observer: NSObjectProtocol?
    private(set) var isRunning = false

    func start() {
        guard !isRunning else { return }
        wasDark = Self.isDark()
        observer = DistributedNotificationCenter.default().addObserver(
            forName: .init("AppleInterfaceThemeChangedNotification"),
            object: nil,
            queue: .main
        ) { [weak self] _ in self?.handle() }
        isRunning = true
    }

    func stop() {
        guard let observer else { return }
        DistributedNotificationCenter.default().removeObserver(observer)
        self.observer = nil
        isRunning = false
    }

    private func handle() {
        let isDark = Self.isDark()
        defer { wasDark = isDark }
        guard isDark, !wasDark else { return }
        Self.reloadSafariTabs()
    }

    private static func isDark() -> Bool {
        CFPreferencesAppSynchronize("NSGlobalDomain" as CFString)
        return UserDefaults.standard.string(forKey: "AppleInterfaceStyle") == "Dark"
    }

    private static func reloadSafariTabs() {
        let src = """
        tell application "Safari" to tell every tab of every window ¬
            to do JavaScript "location.reload()"
        """
        var err: NSDictionary?
        NSAppleScript(source: src)?.executeAndReturnError(&err)
        if let err { fputs("Safari reload failed: \(err)\n", stderr) }
    }
}
