import UIKit

class OnboardingViewController: ViewController<OnboardingView> {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mainView.continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
    }
    
    
    
    @objc private func continueButtonTapped() {
        let conncectVC = ConnectWalletViewController()
        
        navigationController?.pushViewController(conncectVC, animated: true)
    }
    
}
