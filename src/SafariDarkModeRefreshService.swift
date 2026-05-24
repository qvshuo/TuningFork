import AppKit

@MainActor final class SafariDarkModeRefreshService {
    private var wasDark = SafariDarkModeRefreshService.isDark()
    private var observer: NSObjectProtocol?
    private(set) var isRunning = false

    func start() {
        guard !isRunning else { return }
        if let observer {
            DistributedNotificationCenter.default().removeObserver(observer)
        }
        wasDark = Self.isDark()
        observer = DistributedNotificationCenter.default().addObserver(
            forName: .init("AppleInterfaceThemeChangedNotification"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            // queue: .main delivers on main thread, but the closure is @Sendable;
            // Task { @MainActor } bridges into the actor-isolated context.
            Task { @MainActor [weak self] in
                self?.handle()
            }
        }
        isRunning = true
    }

    func stop() {
        if let observer {
            DistributedNotificationCenter.default().removeObserver(observer)
            self.observer = nil
        }
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
        Task.detached {
            let src = """
            tell application "Safari" to tell every tab of every window ¬
                to do JavaScript "location.reload()"
            """
            var err: NSDictionary?
            NSAppleScript(source: src)?.executeAndReturnError(&err)
            if let err { fputs("Safari reload failed: \(err)\n", stderr) }
        }
    }
}
