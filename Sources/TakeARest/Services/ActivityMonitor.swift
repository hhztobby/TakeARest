import AppKit
import Observation

@MainActor
@Observable
class ActivityMonitor {
    var lastActivityTime: Date = Date()
    var isUserActive: Bool = true

    func start() {
        let mask: NSEvent.EventTypeMask = [
            .keyDown, .keyUp,
            .mouseMoved, .leftMouseDragged, .rightMouseDragged,
            .leftMouseDown, .rightMouseDown,
            .scrollWheel
        ]

        NSEvent.addGlobalMonitorForEvents(matching: mask) { [weak self] _ in
            self?.lastActivityTime = Date()
        }
    }

    func checkActivity(threshold: TimeInterval) -> Bool {
        let elapsed = Date().timeIntervalSince(lastActivityTime)
        isUserActive = elapsed < threshold
        return isUserActive
    }

    // 检查是否有辅助功能权限
    static func hasAccessibilityPermission() -> Bool {
        return AXIsProcessTrusted()
    }

    // 请求辅助功能权限
    static func requestAccessibilityPermission() {
        let options: NSDictionary = ["AXTrustedCheckOptionPrompt": true]
        AXIsProcessTrustedWithOptions(options as CFDictionary)
    }
}
