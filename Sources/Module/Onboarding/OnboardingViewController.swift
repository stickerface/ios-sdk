import UIKit

class OnboardingViewController: ViewController<OnboardingView> {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainView.continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
    }
    
    @objc private func continueButtonTapped() {
        let conncectVC = ConnectWalletViewController()

        navigationController?.pushViewController(conncectVC, animated: true)
        
//        let avatarVC = GenerateAvatarViewController()
//
//        navigationController?.pushViewController(avatarVC, animated: true)
        
//        let vc = StickerFaceViewController(type: .main, layers: ImageLoader.defaultLayers)
//        vc.modalPresentationStyle = .fullScreen
//
//        navigationController?.pushViewController(vc, animated: true)
    }
    
}
