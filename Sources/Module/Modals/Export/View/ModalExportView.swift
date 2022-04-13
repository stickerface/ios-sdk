import UIKit

class ModalExportView: RootView {
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Export"
        label.font = Palette.fontBold.withSize(24)
        label.textColor = .sfTextPrimary
        label.textAlignment = .center
        
        return label
    }()
    
    // TODO: attributed label
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Use all stickers in Telegram, WhatsApp or native keyboard"
        label.font = Palette.fontMedium.withSize(16)
        label.textColor = .sfTextPrimary
        label.textAlignment = .center
        label.numberOfLines = 0
        
        return label
    }()
    
    let leftImageView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 65.0
        view.clipsToBounds = true
        
        return view
    }()
    
    let centerImageView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 87.0
        view.clipsToBounds = true
        
        return view
    }()
    
    let rightImageView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 65.0
        view.clipsToBounds = true
        
        return view
    }()
    
    let shareStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 24
        view.distribution = .fillEqually
        
        return view
    }()
    
    let centerImageBackView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear   
        view.layer.cornerRadius = 90.0
        
        return view
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
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(leftImageView)
        containerView.addSubview(rightImageView)
        containerView.addSubview(centerImageBackView)
        containerView.addSubview(centerImageView)
        containerView.addSubview(shareStackView)
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
        
        subtitleLabel.pin
            .top(to: titleLabel.edge.bottom).marginTop(8.0)
            .left()
            .right()
            .sizeToFit(.width)
        
        centerImageView.pin
            .top(to: subtitleLabel.edge.bottom).marginTop(40.0)
            .hCenter()
            .size(174.0)
        
        centerImageBackView.pin
            .center(to: centerImageView.anchor.center)
            .size(180.0)
        
        leftImageView.pin
            .left(29.0)
            .vCenter(to: centerImageView.edge.vCenter)
            .size(130.0)
        
        rightImageView.pin
            .right(29.0)
            .vCenter(to: centerImageView.edge.vCenter)
            .size(130.0)
        
        shareStackView.pin
            .top(to: centerImageView.edge.bottom).marginTop(48.0)
            .left(67.0)
            .right(67.0)
            .height(86.0)
        
        bottomView.pin
            .top(to: shareStackView.edge.bottom)
            .left()
            .right()
            .height(UIScreen.main.bounds.height)
        
        containerView.pin
            .height(shareStackView.frame.maxY + 24.0 + Utils.safeArea().bottom)
        
        pin.height(bottomView.frame.maxY)
    }
    
}
