import SwiftUI
import Observation
import AppKit

@MainActor
@Observable
final class AppState {
    var isRoundedCornersEnabled = false
    var isSafariDarkModeRefreshEnabled = false
    var isNaiveProxyEnabled = false

    private let roundedCorners = RoundedCornersService()
    private let safariDarkModeRefresh = SafariDarkModeRefreshService()
    @ObservationIgnored private let naiveProxy: NaiveProxyService

    init() {
        naiveProxy = NaiveProxyService()
        naiveProxy.onRunningStateChange = { [weak self] isRunning in
            self?.isNaiveProxyEnabled = isRunning
        }
    }

    func startDefaults() {
        setRoundedCorners(enabled: true)
        setSafariDarkModeRefresh(enabled: true)
    }

    func toggleRoundedCorners() {
        setRoundedCorners(enabled: !isRoundedCornersEnabled)
    }

    func toggleSafariDarkModeRefresh() {
        setSafariDarkModeRefresh(enabled: !isSafariDarkModeRefreshEnabled)
    }

    func toggleNaiveProxy() {
        setNaiveProxy(enabled: !isNaiveProxyEnabled)
    }

    func stopAll() {
        setRoundedCorners(enabled: false)
        setSafariDarkModeRefresh(enabled: false)
        setNaiveProxy(enabled: false)
    }

    private func setRoundedCorners(enabled: Bool) {
        guard isRoundedCornersEnabled != enabled else { return }
        if enabled {
            roundedCorners.start()
        } else {
            roundedCorners.stop()
        }
        isRoundedCornersEnabled = enabled
    }

    private func setSafariDarkModeRefresh(enabled: Bool) {
        guard isSafariDarkModeRefreshEnabled != enabled else { return }
        if enabled {
            safariDarkModeRefresh.start()
        } else {
            safariDarkModeRefresh.stop()
        }
        isSafariDarkModeRefreshEnabled = enabled
    }

    private func setNaiveProxy(enabled: Bool) {
        guard isNaiveProxyEnabled != enabled else { return }
        if enabled {
            isNaiveProxyEnabled = naiveProxy.start()
        } else {
            naiveProxy.stop()
        }
    }
}

@main
struct TuningForkApp: App {
    @State private var state: AppState

    init() {
        let state = AppState()
        state.startDefaults()
        _state = State(initialValue: state)
    }

    var body: some Scene {
        MenuBarExtra {
            Button(action: state.toggleRoundedCorners) {
                menuTitle("Rounded Corners", isEnabled: state.isRoundedCornersEnabled)
            }

            Button(action: state.toggleSafariDarkModeRefresh) {
                menuTitle("Refresh Safari Tabs on Dark Mode", isEnabled: state.isSafariDarkModeRefreshEnabled)
            }

            Button(action: state.toggleNaiveProxy) {
                menuTitle("Start Proxy", isEnabled: state.isNaiveProxyEnabled)
            }

            Divider()

            Button("Quit") {
                state.stopAll()
                NSApplication.shared.terminate(nil)
            }
        } label: {
            Image(systemName: "tuningfork")
        }
        .menuBarExtraStyle(.menu)
    }

    @ViewBuilder
    private func menuTitle(_ title: String, isEnabled: Bool) -> some View {
        if isEnabled {
            Label(title, systemImage: "checkmark")
        } else {
            Text(title)
        }
    }
}
