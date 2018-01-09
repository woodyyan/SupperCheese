
import Cocoa

let cropViewLineWidth: CGFloat = 3.0

class CaptureView: NSView {
    
    var trackingArea: NSTrackingArea?
    var phaseCount: CGFloat = 0.0
    var lineDashStatus = 0
    
    override func awakeFromNib() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
        Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(timerAnimation(_:)), userInfo: nil, repeats: true)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        drawBox()
    }
    
    func drawBox() {
        let frame = self.frame
        let width = cropViewLineWidth
        
        NSColor(deviceRed: 1.0, green: 0.0, blue: 0.0, alpha: 0.8).set()
        
        let path = NSBezierPath(rect: frame)
        let context = NSGraphicsContext.current
        context?.saveGraphicsState()
        context?.shouldAntialias = false
        
        path.lineWidth = width
        
        phaseCount += 1.0
        if phaseCount >= 6.0 {
            phaseCount = 0.0
        }
        
        let pattern:[CGFloat] = [3.0, 3.0]
        path.setLineDash(pattern, count: 2, phase: phaseCount)
        path.stroke()
        
        context?.restoreGraphicsState()
    }
    
    @objc func timerAnimation(_ timer:Timer) {
        
        needsDisplay = true
    }
}

