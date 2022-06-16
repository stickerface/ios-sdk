import UIKit
import SafariServices

class OnboardingViewController: ViewController<OnboardingView> {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SFDefaults.isOnboardingShown = true
        
        mainView.continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        
        setupSubtitle()
    }
    
    @objc private func continueButtonTapped() {
        let conncectVC = ConnectWalletViewController()

        navigationController?.pushViewController(conncectVC, animated: true)
    }
    
    private func setupSubtitle() {        
        mainView.policyLabel.onClick = { [weak self] label, detection in
            switch detection.type {
            case .tag(let tag):
                if tag.name == "a", let href = tag.attributes["href"], let url = URL(string: href) {
                    self?.present(SFSafariViewController(url: url), animated: true)
                }
            default:
                break
            }
        }
    }
}
