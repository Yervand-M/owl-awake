import AppKit

/// Minimal owl drawn in an 18×18 unit grid (origin bottom-left).
/// Shared by the menu bar icon and the app icon generator.
enum OwlShape {
    static func head(in rect: NSRect) -> NSBezierPath {
        let p = NSBezierPath()
        func pt(_ x: CGFloat, _ y: CGFloat) -> NSPoint {
            NSPoint(x: rect.minX + x / 18 * rect.width, y: rect.minY + y / 18 * rect.height)
        }
        p.move(to: pt(3.2, 16.6))
        p.curve(to: pt(9, 1.4), controlPoint1: pt(1.2, 11), controlPoint2: pt(2.6, 1.4))
        p.curve(to: pt(14.8, 16.6), controlPoint1: pt(15.4, 1.4), controlPoint2: pt(16.8, 11))
        p.curve(to: pt(9, 14.2), controlPoint1: pt(13, 15.2), controlPoint2: pt(11, 14.2))
        p.curve(to: pt(3.2, 16.6), controlPoint1: pt(7, 14.2), controlPoint2: pt(5, 15.2))
        p.close()
        return p
    }

    static func eyeCenters(in rect: NSRect) -> [NSPoint] {
        [6.2, 11.8].map { NSPoint(x: rect.minX + $0 / 18 * rect.width, y: rect.minY + 9.6 / 18 * rect.height) }
    }

    static func eyeRadius(in rect: NSRect) -> CGFloat { 2.4 / 18 * rect.width }

    static func beak(in rect: NSRect) -> NSBezierPath {
        let p = NSBezierPath()
        func pt(_ x: CGFloat, _ y: CGFloat) -> NSPoint {
            NSPoint(x: rect.minX + x / 18 * rect.width, y: rect.minY + y / 18 * rect.height)
        }
        p.move(to: pt(8.1, 7.6))
        p.line(to: pt(9, 5.9))
        p.line(to: pt(9.9, 7.6))
        p.close()
        return p
    }

    /// Template image for the menu bar: open eyes = awake, closed eyes = normal sleep.
    static func menuBarImage(awake: Bool) -> NSImage {
        let size = NSSize(width: 18, height: 18)
        let image = NSImage(size: size, flipped: false) { rect in
            NSColor.black.set()
            let outline = head(in: rect)
            outline.lineWidth = 1.4
            outline.lineJoinStyle = .round
            outline.stroke()

            let r = eyeRadius(in: rect)
            for c in eyeCenters(in: rect) {
                if awake {
                    let ring = NSBezierPath(ovalIn: NSRect(x: c.x - r, y: c.y - r, width: r * 2, height: r * 2))
                    ring.lineWidth = 1.2
                    ring.stroke()
                    let pr = r * 0.45
                    NSBezierPath(ovalIn: NSRect(x: c.x - pr, y: c.y - pr, width: pr * 2, height: pr * 2)).fill()
                } else {
                    let lid = NSBezierPath()
                    lid.move(to: NSPoint(x: c.x - r, y: c.y + 0.3))
                    lid.curve(to: NSPoint(x: c.x + r, y: c.y + 0.3),
                              controlPoint1: NSPoint(x: c.x - r * 0.5, y: c.y - r * 0.8),
                              controlPoint2: NSPoint(x: c.x + r * 0.5, y: c.y - r * 0.8))
                    lid.lineWidth = 1.2
                    lid.lineCapStyle = .round
                    lid.stroke()
                }
            }
            beak(in: rect).fill()
            return true
        }
        image.isTemplate = true
        return image
    }
}
