import AppKit
import Foundation
import UserNotifications

final class AppNotifier {
    static let shared = AppNotifier()

    private var hasRequestedAuthorization = false

    private init() {}

    func requestAuthorizationIfNeeded() {
        guard !hasRequestedAuthorization else { return }
        hasRequestedAuthorization = true
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    func notify(title: String, body: String) {
        requestAuthorizationIfNeeded()

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body.isEmpty ? "Unknown error." : body
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }
}

final class NaiveProxyService {
    private let configPath = ("~/.config/naiveproxy/config.json" as NSString).expandingTildeInPath
    var onRunningStateChange: ((Bool) -> Void)?

    private var process: Process?
    private var stdoutPipe: Pipe?
    private var stderrPipe: Pipe?
    private var capturedOutput = ""
    private var isStopping = false

    private(set) var isRunning = false

    func start() -> Bool {
        guard process == nil else { return true }

        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: configPath) else {
            notify("NaïveProxy 配置文件不存在。")
            return false
        }

        guard let executablePath = Bundle.main.path(forAuxiliaryExecutable: "naive"),
              fileManager.isExecutableFile(atPath: executablePath) else {
            notify("Bundled naive executable is missing or not executable.")
            return false
        }

        let process = Process()
        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()

        self.process = process
        self.stdoutPipe = stdoutPipe
        self.stderrPipe = stderrPipe
        capturedOutput = ""
        isStopping = false

        process.executableURL = URL(fileURLWithPath: executablePath)
        process.arguments = [configPath]
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe
        process.terminationHandler = { [weak self] process in
            self?.handleTermination(process)
        }

        installReadHandler(for: stdoutPipe)
        installReadHandler(for: stderrPipe)

        do {
            try process.run()
            isRunning = true
            return true
        } catch {
            teardownProcess()
            notify(error.localizedDescription)
            return false
        }
    }

    func stop() {
        guard let process else { return }
        isStopping = true
        isRunning = false

        if process.isRunning {
            process.terminate()
        }

        if process.isRunning {
            process.waitUntilExit()
        }

        teardownProcess()
    }

    private func installReadHandler(for pipe: Pipe) {
        pipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            guard !data.isEmpty, let text = String(data: data, encoding: .utf8) else { return }
            self?.capturedOutput.append(text)
        }
    }

    private func handleTermination(_ process: Process) {
        let exitOutput = capturedOutput.trimmingCharacters(in: .whitespacesAndNewlines)
        let shouldNotify = !isStopping && process.terminationStatus != 0

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.isRunning = false
            self.teardownProcess()
            self.onRunningStateChange?(false)
            if shouldNotify {
                self.notify(exitOutput)
            }
        }
    }

    private func teardownProcess() {
        stdoutPipe?.fileHandleForReading.readabilityHandler = nil
        stderrPipe?.fileHandleForReading.readabilityHandler = nil
        stdoutPipe = nil
        stderrPipe = nil
        process = nil
        capturedOutput = ""
        isStopping = false
    }

    private func notify(_ body: String) {
        DispatchQueue.main.async {
            AppNotifier.shared.notify(title: "TuningFork", body: body)
        }
    }
}
