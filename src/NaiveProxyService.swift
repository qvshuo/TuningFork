import Foundation

@MainActor final class NaiveProxyService {
    private let configPath = ("~/.config/naiveproxy/config.json" as NSString).expandingTildeInPath
    var onRunningStateChange: ((Bool) -> Void)?

    private var process: Process?
    private var stdoutPipe: Pipe?
    private var stderrPipe: Pipe?
    private var capturedOutput = ""
    private var isStopping = false

    private(set) var isRunning = false

    func start() -> Bool {
        if let process {
            if process.isRunning { return true }
            teardownProcess()
        }

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
            Task { @MainActor [weak self] in
                self?.handleTermination(process)
            }
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
        onRunningStateChange?(false)

        if process.isRunning {
            process.terminate()
        } else {
            teardownProcess()
        }
    }

    private func installReadHandler(for pipe: Pipe) {
        pipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            guard !data.isEmpty, let text = String(data: data, encoding: .utf8) else { return }
            Task { @MainActor [weak self] in
                self?.capturedOutput.append(text)
            }
        }
    }

    private func handleTermination(_ process: Process) {
        let wasStopping = isStopping
        let exitOutput = capturedOutput.trimmingCharacters(in: .whitespacesAndNewlines)
        let shouldNotify = !wasStopping && process.terminationStatus != 0

        isRunning = false
        teardownProcess()

        if !wasStopping {
            onRunningStateChange?(false)
        }

        if shouldNotify {
            notify(exitOutput)
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
        AppNotifier.shared.notify(title: "TuningFork", body: body)
    }
}
