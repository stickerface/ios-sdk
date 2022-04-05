import UIKit

class ModalBuyView: UIView {

    let type: ModalBuyController.BuyType
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .sfTextPrimary
        label.font = Palette.fontBold.withSize(20)
        label.text = "Connect crypto wallet"
        label.textAlignment = .center
        
        return label
    }()
    
    // TODO: add attributed label
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .sfTextPrimary
        label.font = Palette.fontBold.withSize(20)
        label.text = "To buy a NFT connect the Tonkepeer"
        label.textAlignment = .center
        label.numberOfLines = 0
        
        return label
    }()
    
    let imageView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.backgroundColor = .purple
        
        return view
    }()
    
    let imageNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .sfTextSecondary
        label.font = Palette.fontMedium.withSize(14)
        label.text = "Checkered shirt"
        label.textAlignment = .center
        label.numberOfLines = 0
        
        return label
    }()
    
    let priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .sfTextPrimary
        label.font = Palette.fontBold.withSize(16)
        label.text = "2,5 TON"
        label.textAlignment = .center
        
        return label
    }()
    
    let priceSubtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .sfTextSecondary
        label.font = Palette.fontMedium.withSize(14)
        label.text = "$5"
        label.textAlignment = .center
        
        return label
    }()
    
    let buyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("connectWalletConnectTitle".libraryLocalized, for: .normal)
        button.titleLabel?.font = Palette.fontBold.withSize(16.0)
        button.setTitleColor(.sfDefaultWhite, for: .normal)
        button.backgroundColor = .sfAccentBrand
        button.layer.cornerRadius = 14.0
        button.setImage(UIImage(libraryNamed: "tonkeeper_1"), for: .normal)
        button.tintColor = .white
        
        return button
    }()
    
    let bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        
        return view
    }()
    
    init(type: ModalBuyController.BuyType) {
        self.type = type
        super.init(frame: .zero)
        
        backgroundColor = .white
        layer.cornerRadius = 23
        
        addSubview(containerView)
        addSubview(bottomView)
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(imageView)
        containerView.addSubview(imageNameLabel)
        containerView.addSubview(priceLabel)
        containerView.addSubview(priceSubtitleLabel)
        containerView.addSubview(buyButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
            .top(to: subtitleLabel.edge.bottom).marginTop(32.0)
            .hCenter()
            .size(197.0)
        
        imageNameLabel.pin
            .top(to: imageView.edge.bottom).marginTop(12.0)
            .left()
            .right()
            .sizeToFit(.width)
        
        priceLabel.pin
            .top(to: imageNameLabel.edge.bottom).marginTop(16.0)
            .left()
            .right()
            .sizeToFit(.width)
        
        priceSubtitleLabel.pin
            .top(to: priceLabel.edge.bottom)
            .left()
            .right()
            .sizeToFit(.width)
        
        buyButton.pin
            .top(to: priceSubtitleLabel.edge.bottom).marginTop(32.0)
            .left(32.0)
            .right(32.0)
            .height(48.0)
                
        bottomView.pin
            .top(to: buyButton.edge.bottom)
            .left()
            .right()
            .height(UIScreen.main.bounds.height)
        
        containerView.pin
            .height(buyButton.frame.maxY + 16.0 + Utils.safeArea().bottom)
        
        pin.height(bottomView.frame.maxY)
    }
}
