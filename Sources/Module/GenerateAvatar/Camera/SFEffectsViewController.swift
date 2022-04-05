import UIKit

class SFEffectsViewController: UIViewController {

    enum Const {
        static let linesCnt = 24
        static let slowRotationDuration: TimeInterval = 15
        static let fastRotationDuration: TimeInterval = 10
    }

    let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    
    var lines: [UIView] = []
    var lastSize: CGFloat = 0
    var lineHeight: CGFloat = 20.0
    var isLoader = false
    var active = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear

        for _ in 0...Const.linesCnt - 1 {
            let line = UIView(frame: .zero)
            line.backgroundColor = .sfAccentBrand
            line.layer.cornerRadius = 2.5
            line.layer.anchorPoint = .zero

            view.addSubview(line)
            lines.append(line)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if lastSize == view.frame.width {
            return
        }
        lastSize = view.frame.width
        update()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        rotate(Const.slowRotationDuration)
    }

}

extension SFEffectsViewController {
    
    func rotate(_ duration: TimeInterval) {
        stopRotate()
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        if let present = view.layer.presentation() {
            let rot = present.value(forKeyPath: "transform.rotation")
            rotationAnimation.fromValue = rot
        } else {
            rotationAnimation.fromValue = 0
        }
        rotationAnimation.toValue = Double.pi * 2.0
        rotationAnimation.duration = duration
        rotationAnimation.repeatCount = Float.infinity
        
        view.layer.add(rotationAnimation, forKey: "infiniteRotationAnimation")
    }
    
    func stopRotate() {
        if view.layer.animation(forKey: "infiniteRotationAnimation") != nil {
            view.layer.removeAnimation(forKey: "infiniteRotationAnimation")
        }
    }
    
    func setState(_ active: Bool) {
        if active == self.active {
            return
        }
        self.active = active

        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            self.update()
        })
        
        rotate(active ? Const.fastRotationDuration : Const.slowRotationDuration)

        if active {
            lightGenerator.impactOccurred()
        }
    }
    
    func loader(_ isLoader: Bool, completion: @escaping(() -> ())) {
        self.isLoader = isLoader
        self.active = isLoader
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.update()
        }, completion: { _ in
            completion()
        })
    }
    
    func update() {
        let center = view.bounds.width / 2
        let curRadius = isLoader ? 24 : view.bounds.width / 2 - 16

        for i in 0...Const.linesCnt - 1 {
            var angle = (CGFloat(360 / Const.linesCnt) * CGFloat(i)) * .pi / 180
            angle += 0.5
            let x = center + curRadius * cos(angle)
            let y = center + curRadius * sin(angle)
            
            self.lines[i].transform  = .identity
            self.lines[i].frame = CGRect(origin: CGPoint(x: x, y: y),
                                         size: CGSize(width: self.lineHeight, height: 4.0))
            
            self.lines[i].transform = CGAffineTransform(rotationAngle: angle)
            
            if isLoader && i % 2 == 0 {
                self.lines[i].alpha = 0
            } else {
                self.lines[i].alpha = 1
            }
        }
    }
}
