import UIKit

class ModalShareView: RootView {

    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "shareTitle".libraryLocalized
        label.font = SFPalette.fontBold.withSize(24)
        label.textColor = .sfTextPrimary
        label.textAlignment = .center
        
        return label
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "shareSubtitle".libraryLocalized
        label.font = SFPalette.fontMedium.withSize(16)
        label.textColor = .sfTextPrimary
        label.textAlignment = .center
        
        return label
    }()
    
    let imageView: UIImageView = {
        let view = UIImageView()
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
        containerView.addSubview(imageView)
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
        
        imageView.pin
            .top(to: subtitleLabel.edge.bottom).marginTop(40.0)
            .hCenter()
            .size(248.0)
        
        shareStackView.pin
            .top(to: imageView.edge.bottom).marginTop(48.0)
            .left(23)
            .right(23)
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
