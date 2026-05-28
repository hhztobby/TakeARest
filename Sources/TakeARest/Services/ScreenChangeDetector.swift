import AppKit
import CoreGraphics
import ScreenCaptureKit
import Observation

@MainActor
@Observable
class ScreenChangeDetector {
    var isScreenChanging: Bool = false

    private var previousFrame: CGImage?
    private var captureTimer: Timer?
    private var captureStream: SCStream?

    func start() {
        Task {
            do {
                let content = try await SCShareableContent.excludingDesktopWindows(
                    false,
                    onScreenWindowsOnly: true
                )
                guard let display = content.displays.first else { return }

                let config = SCStreamConfiguration()
                config.width = 32
                config.height = 32
                config.minimumFrameInterval = CMTime(value: 1, timescale: 1) // 1 FPS
        config.queueDepth = 1

                let filter = SCContentFilter(display: display, excludingWindows: [])
                let stream = SCStream(filter: filter, configuration: config, delegate: nil)

                let output = ScreenCaptureOutput()
                try stream.addStreamOutput(output, type: .screen, sampleHandlerQueue: .main)

                try await stream.startCapture()
                self.captureStream = stream

                output.onFrame = { [weak self] image in
                    Task { @MainActor in
                        self?.processFrame(image)
                    }
                }
            } catch {
                print("屏幕捕获启动失败: \(error)")
            }
        }
    }

    func stop() {
        Task {
            try? await captureStream?.stopCapture()
            captureStream = nil
            previousFrame = nil
        }
    }

    private func processFrame(_ image: CGImage) {
        guard let prev = previousFrame else {
            previousFrame = image
            return
        }

        let diff = calculateFrameDifference(prev, image)
        isScreenChanging = diff > 0.01 // 1% 变化阈值
        previousFrame = image
    }

    private func calculateFrameDifference(_ frame1: CGImage, _ frame2: CGImage) -> Double {
        guard let provider1 = frame1.dataProvider,
              let provider2 = frame2.dataProvider,
              let data1 = provider1.data,
              let data2 = provider2.data else { return 0 }

        let ptr1 = CFDataGetBytePtr(data1)!
        let ptr2 = CFDataGetBytePtr(data2)!
        let length = CFDataGetLength(data1)

        guard length == CFDataGetLength(data2) else { return 0 }

        var totalDiff: Double = 0
        let pixelCount = length / 4 // RGBA

        for i in stride(from: 0, to: length, by: 4) {
            let r1 = Double(ptr1[i])
            let g1 = Double(ptr1[i + 1])
            let b1 = Double(ptr1[i + 2])

            let r2 = Double(ptr2[i])
            let g2 = Double(ptr2[i + 1])
            let b2 = Double(ptr2[i + 2])

            let diff = abs(r1 - r2) + abs(g1 - g2) + abs(b1 - b2)
            totalDiff += diff / (255.0 * 3.0)
        }

        return totalDiff / Double(pixelCount)
    }

    // 检查是否有屏幕录制权限
    static func hasScreenCapturePermission() -> Bool {
        // ScreenCaptureKit 会在第一次使用时自动请求权限
        return true
    }
}

// 用于接收屏幕帧的输出类
class ScreenCaptureOutput: NSObject, SCStreamOutput {
    var onFrame: ((CGImage) -> Void)?

    func stream(
        _ stream: SCStream,
        didOutputSampleBuffer sampleBuffer: CMSampleBuffer,
        of type: SCStreamOutputType
    ) {
        guard type == .screen,
              let imageBuffer = sampleBuffer.imageBuffer else { return }

        let ciImage = CIImage(cvImageBuffer: imageBuffer)
        let context = CIContext()
        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            onFrame?(cgImage)
        }
    }
}
