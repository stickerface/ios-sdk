import UIKit
import SnapKit

class OnboardingView: RootView {

    // TODO: add localize
    let continueButton: UIButton = {
        let button = UIButton()
        button.setTitle("Continue", for: .normal)
        button.titleLabel?.font = Palette.fontBold.withSize(16.0)
        button.setTitleColor(.defaultWhite, for: .normal)
        button.backgroundColor = .accentBrand
        button.layer.cornerRadius = 14.0
        
        return button
    }()
    
    override func setup() {
        backgroundColor = .white
        
        addSubview(continueButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        continueButton.snp.makeConstraints { make in
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-16)
            make.left.equalToSuperview().offset(32)
            make.right.equalToSuperview().offset(-32)
            make.height.equalTo(48)
        }
    }
    
}
