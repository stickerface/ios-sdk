import UIKit
import PinLayout
import Atributika

protocol ModalSettingsControllerDelegate: AnyObject {
    func confirmBuyLayers(controller: ModalSettingsController)
}

class ModalSettingsController: ModalScrollViewController {
    
    let settingsView = ModalSettingsView()
    let loaderView = LoaderView()
    
    var models = [ModalSettingsModel]()
    
    weak var delegate: ModalSettingsControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupModels()
        
        settingsView.tableView.delegate = self
        settingsView.tableView.dataSource = self
        
        scrollView.addSubview(settingsView)
        view.addSubview(loaderView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        layout()
    }
    
    // MARK: Private actions
    
    private lazy var languageAction: Action = { [weak self] in
        guard let self = self else { return }
        
    }
    
    private lazy var faqAction: Action = { [weak self] in
        guard let self = self else { return }
        
    }
    
    private lazy var rateAction: Action = { [weak self] in
        guard let self = self else { return }
        
    }
    
    private lazy var aboutAction: Action = { [weak self] in
        guard let self = self else { return }
        
    }
    
    // MARK: Private methods
    
    private func setupModels() {
        models = [
            ModalSettingsModel(title: "Language",
                               image: UIImage(libraryNamed: "language"),
                               action: languageAction),
            ModalSettingsModel(title: "FAQ",
                               image: UIImage(libraryNamed: "FAQ"),
                               action: faqAction),
            ModalSettingsModel(title: "Rate us",
                               image: UIImage(libraryNamed: "icon-24_outline"),
                               action: rateAction),
            ModalSettingsModel(title: "About app",
                               image: UIImage(libraryNamed: "info"),
                               action: aboutAction)
        ]
    }
    
    private func layout() {
        settingsView.pin.below(of: hideIndicatorView).marginTop(12.0).left().width(contentWidth)

        settingsView.layoutIfNeeded()
        
        contentHeight = settingsView.bounds.height
    }
    
}

// MARK: UITableViewDelegate
extension ModalSettingsController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ModalSettingsCell.description(), for: indexPath) as! ModalSettingsCell
        
        cell.titleLabel.text = models[indexPath.row].title
        cell.rightImageView.image = models[indexPath.row].image
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        models[indexPath.row].action()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48.0
    }
}
