import UIKit

class ProgressView: UIView {
    
    var started = false {
        didSet {
            if started {
                DispatchQueue.main.async {
                    self.setNeedsDisplay()
                }
            }
        }
    }

    override var isHidden: Bool {
        didSet {
            setNeedsDisplay()
        }
    }

    static let T = Float(1) / Float(13)
    static let FIRST_FROM = Float(1) * T
    static let FIRST_TO = Float(7) * T
    static let SECOND_FROM = Float(3) * T
    static let SECOND_TO = Float(9) * T
    static let THIRD_FROM = Float(5) * T
    static let THIRD_TO = Float(11) * T

    let animationDuration = Float(1200)
    var animationProgress = Float(0)
    var lastUpdateTime: TimeInterval = 0

    override init(frame: CGRect) {
        super.init(frame: frame)

        tintColor = .sfAccentBrand
        backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        
        if isHidden {
            return
        }
 
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return
        }

        ctx.clear(rect)
        ctx.setFillColor(tintColor.cgColor)

        let newTime = NSDate().timeIntervalSince1970 * 1000.0
        let dt = Float(newTime - self.lastUpdateTime)
        self.lastUpdateTime = newTime
        self.animationProgress += dt / self.animationDuration
        self.animationProgress = modf(self.animationProgress).1
        
        let radius = CGFloat(rect.height / 2)
        self.drawCircle(ctx, radius, radius + 1, radius, ProgressView.FIRST_FROM, ProgressView.FIRST_TO)
        self.drawCircle(ctx, radius, CGFloat(rect.width) / 2,  radius, ProgressView.SECOND_FROM, ProgressView.SECOND_TO)
        self.drawCircle(ctx, radius, CGFloat(rect.width) - radius - CGFloat(1), radius, ProgressView.THIRD_FROM, ProgressView.THIRD_TO)

        if self.animationProgress > 1 {
            return
        }
        
        DispatchQueue.main.async {
            self.setNeedsDisplay()
        }
    }
    
    func drawCircle(_ ctx: CGContext,
                    _ radius: CGFloat,
                    _ x: CGFloat,
                    _ y: CGFloat,
                    _ progressFrom: Float,
                    _ progressTo: Float) {
        
        if (animationProgress >= progressFrom && animationProgress <= progressTo) {
            let realProgress = CGFloat(min(max((animationProgress - progressFrom) / (progressTo - progressFrom), Float(0)), Float(1)))
            
            let realRadius = realProgress <= 0.5 ?
                interpolate(realProgress * 2.0, 0.0, radius) :
                interpolate((CGFloat(1.0) - realProgress) * 2.0, 0.0, radius)
            
            ctx.addPath(UIBezierPath(arcCenter: CGPoint(x: x, y: y), radius: realRadius, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: false).cgPath)
            ctx.fillPath()
        }
        
    }
    
    func interpolate(_ amount: CGFloat, _ min: CGFloat, _ max: CGFloat) -> CGFloat {
        return min + amount * (max - min)
    }

}
