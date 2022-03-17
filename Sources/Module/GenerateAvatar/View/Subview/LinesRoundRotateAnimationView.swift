import UIKit
import SpriteKit

class LinesRoundRotateAnimationView: UIView {
    
    enum Layout {
        static let side: CGFloat = 326.0
    }
    
    enum LineType {
        case dot, line
    }

    private let linesCount = 24
    private let radius: CGFloat = 148.0
    private let dotSize: CGFloat = 5.0
    private let lineHeight: CGFloat = 4.0
    private let lineWidth: CGFloat = 16.0
    private let shapeLayer = CAShapeLayer()
    
    private var lines: [UIView] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear

        initLines()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initLines() {
        for _ in 0..<linesCount {
            let line = UIView()
            line.backgroundColor = .sfAccentBrand
            line.layer.cornerRadius = 1.25
            line.layer.anchorPoint = .zero

            addSubview(line)
            lines.append(line)
        }
    }
    
    func start() {
        stop()
        update(lineType: .dot)
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.toValue = Double.pi * 2.0
        rotationAnimation.duration = 10.0
        rotationAnimation.repeatCount = Float.infinity
        
        if let present = layer.presentation() {
            rotationAnimation.fromValue = present.value(forKeyPath: "transform.rotation")
        } else {
            rotationAnimation.fromValue = 0.0
        }
        
        layer.add(rotationAnimation, forKey: "infiniteRotationAnimation")
    }
    
    func stop() {
        layer.removeAnimation(forKey: "infiniteRotationAnimation")
    }
    
    func update(lineType: LineType) {
        let center = Layout.side / 2
        let lineHeight = lineType == .dot ? dotSize : lineHeight
        let lineWidth = lineType == .dot ? dotSize : lineWidth
        let radius = radius

        for i in 0..<linesCount {
            var angle: CGFloat = (CGFloat(360 / linesCount) * CGFloat(i)) * .pi / 180
            angle += 0.5
            let x = center + radius * cos(angle)
            let y = center + radius * sin(angle)

            lines[i].transform  = .identity
            lines[i].frame = CGRect(origin: CGPoint(x: x, y: y),
                                    size: CGSize(width: lineWidth, height: lineHeight))

            lines[i].transform = CGAffineTransform(rotationAngle: angle)
        }
    }
    
}
