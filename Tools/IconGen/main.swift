import AppKit

// Renders the Owl Awake app icon into an .iconset folder (TCL Core palette).
// Usage: icongen <output.iconset>

let out = CommandLine.arguments[1]
try? FileManager.default.createDirectory(atPath: out, withIntermediateDirectories: true)

let green = NSColor(red: 0x00 / 255, green: 0x4F / 255, blue: 0x3E / 255, alpha: 1)   // #004F3E
let depth = NSColor(red: 0x16 / 255, green: 0x35 / 255, blue: 0x2D / 255, alpha: 1)   // #16352D
let cream = NSColor(red: 0xF7 / 255, green: 0xF2 / 255, blue: 0xEB / 255, alpha: 1)   // #F7F2EB
let gold = NSColor(red: 0xD9 / 255, green: 0xA4 / 255, blue: 0x41 / 255, alpha: 1)

func render(_ px: Int) -> Data {
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: px, pixelsHigh: px, bitsPerSample: 8,
                               samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                               colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    let s = CGFloat(px)

    // macOS icon grid: 824/1024 body with ~185/1024 corner radius.
    let inset = s * 100 / 1024
    let tile = NSRect(x: inset, y: inset, width: s - inset * 2, height: s - inset * 2)
    let radius = tile.width * 0.225
    NSGradient(starting: green, ending: depth)!
        .draw(in: NSBezierPath(roundedRect: tile, xRadius: radius, yRadius: radius), angle: -90)

    let owlSize = tile.width * 0.62
    let owl = NSRect(x: tile.midX - owlSize / 2, y: tile.midY - owlSize / 2 - tile.width * 0.01,
                     width: owlSize, height: owlSize)
    cream.setFill()
    OwlShape.head(in: owl).fill()

    let r = OwlShape.eyeRadius(in: owl) * 1.15
    for c in OwlShape.eyeCenters(in: owl) {
        depth.setFill()
        NSBezierPath(ovalIn: NSRect(x: c.x - r, y: c.y - r, width: r * 2, height: r * 2)).fill()
        let pr = r * 0.5
        gold.setFill()
        NSBezierPath(ovalIn: NSRect(x: c.x - pr, y: c.y - pr, width: pr * 2, height: pr * 2)).fill()
    }
    gold.setFill()
    OwlShape.beak(in: owl).fill()

    NSGraphicsContext.restoreGraphicsState()
    return rep.representation(using: .png, properties: [:])!
}

for base in [16, 32, 128, 256, 512] {
    try render(base).write(to: URL(fileURLWithPath: "\(out)/icon_\(base)x\(base).png"))
    try render(base * 2).write(to: URL(fileURLWithPath: "\(out)/icon_\(base)x\(base)@2x.png"))
}
