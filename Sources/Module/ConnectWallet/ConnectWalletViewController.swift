import UIKit

class ConnectWalletViewController: ViewController<ConnectWalletView> {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mainView.continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
    }
    
    @objc private func continueButtonTapped() {
        navigationController?.pushViewController(GenerateAvatarViewController(), animated: false)
    }
    
}
