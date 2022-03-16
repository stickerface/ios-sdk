import UIKit

public class ViewController<View: RootView>: UIViewController {
    
    var mainView: View! { view as? View }
    
    public override func loadView() {
        self.view = View()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        mainView.didLoad()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mainView.willAppear()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mainView.willDisappear()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mainView.didAppear()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        mainView.didDisappear()
    }
}
