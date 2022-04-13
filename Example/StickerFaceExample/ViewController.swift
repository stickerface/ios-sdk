import UIKit
import StickerFace
import SnapKit

class ViewController: UIViewController {

    let sdk = StickerFace.shared
    
    let openButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.white, for: .normal)
        button.setTitle("StickerFace", for: .normal)
        button.backgroundColor = UIColor(red: 0.271, green: 0.682, blue: 0.961, alpha: 1)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.layer.cornerRadius = 14
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.addSubview(openButton)
        
        openButton.addTarget(self, action: #selector(openButtonTapped), for: .touchUpInside)
        
        setupConstraints()
    }
    
    @objc private func openButtonTapped() {
        sdk.openStickerFace()
    }
    
    private func setupConstraints() {
        openButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
            make.left.equalToSuperview().offset(32)
            make.right.equalToSuperview().offset(-32)
            make.height.equalTo(48)
        }
    }
    
}

