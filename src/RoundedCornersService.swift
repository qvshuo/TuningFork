import AppKit

enum ScreenCorner: CaseIterable {
    case topLeft, topRight, bottomLeft, bottomRight

    private var isRight: Bool { self == .topRight || self == .bottomRight }
    private var isTop: Bool { self == .topLeft || self == .topRight }
    private var isLeft: Bool { !isRight }
    private var isBottom: Bool { !isTop }

    func frame(in screen: NSRect, radius r: CGFloat) -> NSRect {
        NSRect(
            x: isRight ? screen.maxX - r : screen.minX,
            y: isTop ? screen.maxY - r : screen.minY,
            width: r, height: r
        )
    }

    func circleCenter(radius r: CGFloat) -> NSPoint {
        NSPoint(x: isLeft ? r : 0, y: isBottom ? r : 0)
    }
}

final class CornerMaskView: NSView {
    init(radius r: CGFloat, corner: ScreenCorner) {
        super.init(frame: NSRect(x: 0, y: 0, width: r, height: r))
        wantsLayer = true

        let c = corner.circleCenter(radius: r)
        let path = CGMutablePath()
        path.addRect(bounds)
        path.addEllipse(in: CGRect(x: c.x - r, y: c.y - r, width: 2 * r, height: 2 * r))

        let shape = CAShapeLayer()
        shape.path = path
        shape.fillRule = .evenOdd
        shape.fillColor = NSColor.black.cgColor
        layer = shape
    }

    required init?(coder: NSCoder) { fatalError() }
}

@MainActor final class RoundedCornersService {
    static let cornerRadius: CGFloat = 20

    private var windows: [NSWindow] = []
    private var screenObserver: NSObjectProtocol?
    private var screenConfigurationSignature = ""
    private(set) var isRunning = false

    func start() {
        guard !isRunning else { return }
        if let screenObserver {
            NotificationCenter.default.removeObserver(screenObserver)
        }
        screenObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil, queue: .main
        ) { [weak self] _ in
            // queue: .main delivers on main thread, but the closure is @Sendable;
            // Task { @MainActor } bridges into the actor-isolated context.
            Task { @MainActor [weak self] in
                self?.rebuildOverlays()
            }
        }

        if windows.isEmpty
            || screenConfigurationSignature != Self.currentScreenConfigurationSignature()
        {
            rebuildOverlays()
        } else {
            showAllOverlays()
        }
        isRunning = true
    }

    func stop() {
        if let screenObserver {
            NotificationCenter.default.removeObserver(screenObserver)
            self.screenObserver = nil
        }
        hideAllOverlays()
        isRunning = false
    }

    private func rebuildOverlays() {
        removeAllOverlays()
        for screen in NSScreen.screens {
            for corner in ScreenCorner.allCases {
                windows.append(makeOverlay(on: screen, corner: corner))
            }
        }
        screenConfigurationSignature = Self.currentScreenConfigurationSignature()
    }

    private func showAllOverlays() {
        windows.forEach { $0.orderFrontRegardless() }
    }

    private func hideAllOverlays() {
        windows.forEach { $0.orderOut(nil) }
    }

    private func removeAllOverlays() {
        windows.forEach {
            $0.orderOut(nil)
            $0.close()
        }
        windows.removeAll()
    }

    private static func currentScreenConfigurationSignature() -> String {
        NSScreen.screens
            .map { screen in
                let frame = screen.frame.integral
                return
                    "\(frame.origin.x),\(frame.origin.y),\(frame.size.width),\(frame.size.height)"
            }
            .joined(separator: "|")
    }

    private func makeOverlay(on screen: NSScreen, corner: ScreenCorner) -> NSWindow {
        let r = Self.cornerRadius
        let window = NSWindow(
            contentRect: corner.frame(in: screen.frame, radius: r),
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.screenSaverWindow)) + 1)
        window.isReleasedWhenClosed = false
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
        window.ignoresMouseEvents = true
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]
        window.contentView = CornerMaskView(radius: r, corner: corner)
        window.orderFrontRegardless()
        return window
    }
}
