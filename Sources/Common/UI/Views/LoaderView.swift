import UIKit
import SnapKit

class LoaderView: UIView {
    
    enum Constants {
        static let size: CGFloat = 96
    }
    
    var keyboardHeight: CGFloat = 0 {
        didSet {
            contentViewCenterYConstraint.update(offset: keyboardHeight > 0.0 ? -keyboardHeight / 2 : 0.0)
        }
    }
    
    private let errorIcon: UIImageView = {
        let errorIcon = UIImageView(frame: CGRect(x: 0, y: 14, width: 28, height: 28))
        errorIcon.image = UIImage(libraryNamed: "close_28")?.withRenderingMode(.alwaysTemplate)
        errorIcon.tintColor = .sfAccentBrand
        errorIcon.isHidden = true
        errorIcon.isUserInteractionEnabled = true
        
        return errorIcon
    }()
    
    private let successIcon: UIImageView = {
        let successIcon = UIImageView(frame: CGRect(x: 24, y: 24, width: 48, height: 48))
        successIcon.image = UIImage(libraryNamed: "check_48")?.withRenderingMode(.alwaysTemplate)
        successIcon.tintColor = .green
        successIcon.isHidden = true
        
        return successIcon
    }()
    
    private let errorLabel: UILabel = {
        let errorLabel = UILabel(frame: CGRect(x: 24, y: 45, width: 0, height: 0))
        errorLabel.font = SFPalette.fontSemiBold
        errorLabel.textAlignment = .center
        errorLabel.isHidden = true
        errorLabel.numberOfLines = 0
        
        return errorLabel
    }()
    
    private lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.backgroundColor = .white
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.layer.cornerRadius = 16
        
        contentView.addSubview(progressView)
        contentView.addSubview(errorLabel)
        contentView.addSubview(errorIcon)
        contentView.addSubview(successIcon)
        
        return contentView
    }()
    
    private let progressView: ProgressView = {
        let size: CGFloat = 8
        let progressView = ProgressView(frame: CGRect(x: 28, y: 44, width: size * 3 + size * 2, height: size))
        
        return progressView
    }()
    
    var contentViewCenterYConstraint: Constraint!
    
    init() {
        super.init(frame: CGRect.zero)
        
        isHidden = true
        layer.zPosition = 100
        
        backgroundColor = UIColor.black.withAlphaComponent(0.24)
        self.frame.size =  UIScreen.main.bounds.size
        
        errorIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hide)))
        
        addSubview(contentView)
        
//        contentView.addShadow()
        
        contentView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            contentViewCenterYConstraint = make.centerY.equalToSuperview().constraint
            make.left.greaterThanOrEqualToSuperview().offset(16.0)
            make.right.lessThanOrEqualToSuperview().offset(-16.0)
            make.size.greaterThanOrEqualTo(96.0)
        }
        
        errorIcon.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8.0)
            make.centerX.equalToSuperview()
            make.size.equalTo(28.0)
        }
        
        successIcon.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(48.0)
        }
        
        errorLabel.snp.makeConstraints { make in
            make.top.equalTo(errorIcon.snp.bottom).offset(8.0)
            make.left.equalToSuperview().offset(16.0)
            make.right.equalToSuperview().offset(-16.0)
            make.bottom.equalToSuperview().offset(-16.0)
        }
        
        progressView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(8.0 * 3 + 8.0 * 2)
            make.height.equalTo(8.0)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func keyboardWillChangeFrame(notification: NSNotification) {
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let offset = keyboardRect.size.height
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            keyboardHeight = 0
        } else {
            keyboardHeight = offset
        }
    }
    
    func showError(_ text: String, completion: (() -> ())? = nil) {
        layer.removeAllAnimations()

//        CATransaction.performWithoutAnimation {
            self.show()
//        }

        progressView.isHidden = true
        errorLabel.isHidden = false
        errorIcon.isHidden = false
        
        errorLabel.text = text
        errorLabel.sizeToFit()
                
        errorLabel.alpha = 0
        errorIcon.alpha = 0
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
            self.layoutIfNeeded()
        }, completion: { ok in
            UIView.animate(withDuration: 0.1, animations: {
                self.errorIcon.alpha = 1
                self.errorLabel.alpha = 1
            }, completion: { ok in
                DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                    self.hide()
                    if completion != nil {
                        completion!()
                    }
                })
            })
        })

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    func show() {
        self.isHidden = false
        errorLabel.isHidden = true
        successIcon.isHidden = true
        errorIcon.isHidden = true
        contentView.isHidden = false
        
        progressView.isHidden = false
        progressView.setNeedsDisplay()
        
        alpha = 0
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
            self.alpha = 1
        }, completion: nil)
    }
    
    @objc func hide() {
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
            self.alpha = 0
        }, completion: { ok in
            self.isHidden = true
        })
    }
    
    func showSuccess(completion: (() -> ())? = nil) {
        successIcon.isHidden = false
        progressView.isHidden = true
        
        successIcon.alpha = 0
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
            self.successIcon.alpha = 1
        }, completion: { ok in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self.hide()
                if completion != nil {
                    completion!()
                }
            })
        })

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
}
