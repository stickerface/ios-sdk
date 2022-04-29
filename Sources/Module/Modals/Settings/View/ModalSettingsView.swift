import UIKit

class ModalSettingsView: RootView {
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Palette.fontBold.withSize(20)
        label.textColor = .sfAccentSecondary
        label.textAlignment = .center
        label.text = "settingsTitle".libraryLocalized
        
        return label
    }()
    
    let tableView: UITableView = {
        let view = UITableView()
        view.register(ModalSettingsCell.self, forCellReuseIdentifier: ModalSettingsCell.description())
        view.separatorStyle = .none
        view.layer.cornerRadius = 16.0
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.sfSeparatorLight.cgColor
        view.backgroundColor = .white
        
        return view
    }()
    
    let tonView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0xF5F7FA)
        view.layer.cornerRadius = 16
        
        return view
    }()
    
    let tonImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(libraryNamed: "tonkeeper_1")
        view.tintColor = .sfAccentBrand
        
        return view
    }()
    
    let tonTitleLabel: UILabel = {
        let label = UILabel()
        label.font = Palette.fontSemiBold.withSize(12)
        label.textColor = .sfTextSecondary
        label.textAlignment = .left
        label.text = "Tonkeeper"
        
        return label
    }()
    
    let tonSubtitleLabel: UILabel = {
        let label = UILabel()
        label.font = Palette.fontBold.withSize(12)
        label.textColor = .sfAccentSecondary
        label.textAlignment = .left
        label.text = "settingsConnectToBuy".libraryLocalized
        
        return label
    }()
    
    let tonConnectButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 12
        button.layer.cornerCurve = .continuous
        button.backgroundColor = .sfAccentBrand
        button.setTitleColor(.sfDefaultWhite, for: .normal)
        button.setTitle("commonConnect".libraryLocalized, for: .normal)
        button.titleLabel?.font = Palette.fontBold.withSize(14)
        button.contentEdgeInsets = UIEdgeInsets(top: 8.0, left: 16.0, bottom: 8.0, right: 16.0)
        
        return button
    }()
    
    let bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        
        return view
    }()
    
    override func setup() {
        backgroundColor = .white
        layer.cornerRadius = 23
        
        addSubview(containerView)
        addSubview(bottomView)
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(tableView)
        containerView.addSubview(tonView)
        
        tonView.addSubview(tonImageView)
        tonView.addSubview(tonTitleLabel)
        tonView.addSubview(tonSubtitleLabel)
        tonView.addSubview(tonConnectButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layout()
    }
    
    private func layout() {
        containerView.pin
            .left()
            .right()
            .top()
        
        titleLabel.pin
            .top(24.0)
            .left()
            .right()
            .sizeToFit(.width)
        
        tableView.pin
            .left(16.0)
            .right(16.0)
            .top(to: titleLabel.edge.bottom).marginTop(24.0)
            .height(48.0 * 4)
        
        tonView.pin
            .left(16.0)
            .right(16.0)
            .top(to: tableView.edge.bottom).marginTop(24.0)
        
        tonConnectButton.pin
            .right(16.0)
            .top(16.0)
            .height(32.0)
            .sizeToFit(.widthFlexible)
        
        tonView.pin.height(tonConnectButton.frame.maxY + 16.0)
        
        tonImageView.pin
            .left(16.0)
            .vCenter()
            .size(32.0)
        
        tonTitleLabel.pin
            .top(to: tonImageView.edge.top)
            .left(to: tonImageView.edge.right).marginLeft(8.0)
            .sizeToFit(.widthFlexible)
        
        tonSubtitleLabel.pin
            .bottom(to: tonImageView.edge.bottom).marginBottom(2.0)
            .left(to: tonImageView.edge.right).marginLeft(8.0)
            .sizeToFit(.widthFlexible)
        
        bottomView.pin
            .top(to: tonView.edge.bottom)
            .left()
            .right()
            .height(UIScreen.main.bounds.height)
        
        containerView.pin
            .height(tonView.frame.maxY + Utils.safeArea().bottom)
        
        pin.height(bottomView.frame.maxY)
    }
}
