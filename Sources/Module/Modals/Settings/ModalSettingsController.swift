import UIKit
import PinLayout

class ModalSettingsController: ModalScrollViewController {
    
    let mainView = ModalSettingsView()
    let loaderView = LoaderView()
    
    var models = [ModalSettingsCellModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupModels()
        
        mainView.tableView.delegate = self
        mainView.tableView.dataSource = self
        
        scrollView.addSubview(mainView)
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
            ModalSettingsCellModel(title: "settingsLanguage".libraryLocalized,
                               image: UIImage(libraryNamed: "language"),
                               action: languageAction),
            ModalSettingsCellModel(title: "FAQ",
                               image: UIImage(libraryNamed: "FAQ"),
                               action: faqAction),
            ModalSettingsCellModel(title: "settingsRate".libraryLocalized,
                               image: UIImage(libraryNamed: "icon-24_outline"),
                               action: rateAction),
            ModalSettingsCellModel(title: "settingsAbout".libraryLocalized,
                               image: UIImage(libraryNamed: "info"),
                               action: aboutAction)
        ]
    }
    
    private func layout() {
        mainView.pin.below(of: hideIndicatorView).marginTop(12.0).left().width(contentWidth)

        mainView.layoutIfNeeded()
        
        contentHeight = mainView.containerView.bounds.height
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
