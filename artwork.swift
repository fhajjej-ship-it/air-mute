// Package the opaque Air Mute master with a standard rounded-square icon mask.
// Usage: swift artwork.swift OPAQUE_MASTER_PNG DESTINATION.iconset
import AppKit
import Foundation

guard CommandLine.arguments.count == 3,
      let source = NSImage(contentsOfFile: CommandLine.arguments[1]) else {
    fatalError("Usage: swift artwork.swift OPAQUE_MASTER_PNG DESTINATION.iconset")
}
let destination = URL(fileURLWithPath: CommandLine.arguments[2])
try FileManager.default.createDirectory(at: destination, withIntermediateDirectories: true)
for logicalSize in [16, 32, 128, 256, 512] {
    for scale in [1, 2] {
        let pixels = logicalSize * scale
        let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: pixels, pixelsHigh: pixels,
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
            colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
        NSGraphicsContext.current?.imageInterpolation = .high
        let edge = CGFloat(pixels)
        let tile = NSRect(x: edge * 0.0625, y: edge * 0.0625,
                          width: edge * 0.875, height: edge * 0.875)
        let mask = NSBezierPath(roundedRect: tile,
                                xRadius: edge * 0.185, yRadius: edge * 0.185)
        mask.addClip()
        source.draw(in: tile,
                    from: .zero, operation: .copy, fraction: 1)
        NSGraphicsContext.restoreGraphicsState()
        let suffix = scale == 2 ? "@2x" : ""
        let filename = "icon_\(logicalSize)x\(logicalSize)\(suffix).png"
        try bitmap.representation(using: .png, properties: [:])!
            .write(to: destination.appendingPathComponent(filename))
    }
}
