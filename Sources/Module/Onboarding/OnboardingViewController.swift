import UIKit

class OnboardingViewController: ViewController<OnboardingView> {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mainView.continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
    }
    
    @objc private func continueButtonTapped() {
        navigationController?.pushViewController(ConnectWalletViewController(), animated: false)
    }
    
}
