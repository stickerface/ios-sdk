import UIKit
import SnapKit

class LoadingView: UIView {
    
    private let progressView: ProgressView = {
        let view = ProgressView()
        view.isHidden = true
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(progressView)
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func play() {
        progressView.isHidden = false
    }
    
    func stop() {
        progressView.isHidden = true
    }
    
    func setAnimationTintColor(_ color: UIColor) {
        progressView.tintColor = color
    }
    
    private func setupConstraints() {
        progressView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(12.0 * 3 + 4.0 * 3)
            make.height.equalTo(12.0)
        }
    }
    
}
