import UIKit
import StickerFaceSDK
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
    
    let avatarImageView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 140.0
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        
        return view
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.addSubview(openButton)
        view.addSubview(avatarImageView)
        
        openButton.addTarget(self, action: #selector(openButtonTapped), for: .touchUpInside)
        
        sdk.delegate = self
        
        setupConstraints()
    }
    
    @objc private func openButtonTapped() {
        sdk.openCreateAvatarController(true)
    }
    
    private func setupConstraints() {
        openButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
            make.left.equalToSuperview().offset(32)
            make.right.equalToSuperview().offset(-32)
            make.height.equalTo(48)
        }
        
        avatarImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(280.0)
        }
    }
    
}

extension ViewController: StickerFaceDelegate {
    func stickerFace(viewController: UIViewController, didReceive avatar: SFAvatar) {
        viewController.dismiss(animated: true)
        avatarImageView.image = UIImage(data: avatar.avatarImage ?? Data())
    }
}
