import UIKit

class ModalShareView: RootView {

    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Share"
        label.font = Palette.fontBold.withSize(24)
        label.textColor = .sfTextPrimary
        label.textAlignment = .center
        
        return label
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Send sticker to friends"
        label.font = Palette.fontMedium.withSize(16)
        label.textColor = .sfTextPrimary
        label.textAlignment = .center
        
        return label
    }()
    
    let imageView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 124.0
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
    
    override func setup() {
        backgroundColor = .white
        layer.cornerRadius = 23
        
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(imageView)
        addSubview(shareStackView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layout()
    }
    
    private func layout() {
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
        
        pin.height(shareStackView.frame.maxY + 24.0 + Utils.safeArea().bottom)
    }

}
