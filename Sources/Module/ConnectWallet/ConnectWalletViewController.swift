import UIKit

class ConnectWalletViewController: ViewController<ConnectWalletView> {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainView.connectButton.addTarget(self, action: #selector(connectButtonTapped), for: .touchUpInside)
        mainView.continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        
        NotificationCenter.default.addObserver(self, selector: #selector(tonClientDidUpdate), name: .tonClientDidUpdate, object: nil)
    }
    
    @objc private func connectButtonTapped() {
        let path = "https://app.tonkeeper.com/ton-login/stickerface.io/api/tonkeeper/authRequest"
        let url = URL(string: path)
        
        if let url = url {
            UIApplication.shared.open(url)
        }
    }
    
    @objc private func continueButtonTapped() {
        navigationController?.pushViewController(GenerateAvatarViewController(), animated: false)
    }
    
    @objc private func tonClientDidUpdate() {
        navigationController?.pushViewController(GenerateAvatarViewController(), animated: false)
    }
    
}
