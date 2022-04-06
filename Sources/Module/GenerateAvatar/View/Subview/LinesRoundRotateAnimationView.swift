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
    private let slowRotationDuration: TimeInterval = 15
    private let fastRotationDuration: TimeInterval = 10
    private var isLoader = false
    private var active = false
    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    
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
            line.layer.anchorPoint = .zero

            addSubview(line)
            lines.append(line)
        }
    }
    
    func rotate(_ duration: TimeInterval = 15) {
        stopRotate()
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.toValue = Double.pi * 2.0
        rotationAnimation.duration = duration
        rotationAnimation.repeatCount = Float.infinity
        
        if let present = layer.presentation() {
            rotationAnimation.fromValue = present.value(forKeyPath: "transform.rotation")
        } else {
            rotationAnimation.fromValue = 0.0
        }
        
        layer.add(rotationAnimation, forKey: "infiniteRotationAnimation")
    }
    
    func stopRotate() {
        layer.removeAnimation(forKey: "infiniteRotationAnimation")
    }
    
    func setState(_ active: Bool) {
        if active == self.active {
            return
        }
        self.active = active

        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            self.update(lineType: .line)
        })
        
        rotate(active ? fastRotationDuration : slowRotationDuration)

        if active {
            lightGenerator.impactOccurred()
        }
    }
    
    func loader(_ isLoader: Bool, completion: @escaping (() -> ())) {
        self.isLoader = isLoader
        self.active = isLoader
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.update(lineType: .line)
        }, completion: { _ in
            completion()
        })
    }
    
    func update(lineType: LineType) {
        let center = Layout.side / 2
        let lineHeight = lineType == .dot ? dotSize : lineHeight
        let lineWidth = lineType == .dot ? dotSize : lineWidth
        let radius: CGFloat = isLoader ? 24.0 : self.radius

        for i in 0..<linesCount {
            var angle: CGFloat = (CGFloat(360 / linesCount) * CGFloat(i)) * .pi / 180
            angle += 0.5
            let x = center + radius * cos(angle)
            let y = center + radius * sin(angle)

            lines[i].transform  = .identity
            lines[i].frame = CGRect(origin: CGPoint(x: x, y: y),
                                    size: CGSize(width: lineWidth, height: lineHeight))

            lines[i].layer.cornerRadius = lineType == .dot ? 2.5 : 1.25
            lines[i].transform = CGAffineTransform(rotationAngle: angle)
            
            if isLoader && i % 2 == 0 {
                lines[i].alpha = 0
            } else {
                lines[i].alpha = 1
            }
        }
    }
    
}
