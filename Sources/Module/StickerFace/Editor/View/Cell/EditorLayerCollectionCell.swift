import UIKit
import PinLayout
import SkeletonView

class EditorLayerCollectionCell: UICollectionViewCell {
    
    var layerType: LayerType = .layers {
        didSet {
            contentView.layer.borderWidth = layerType == .background ? 0 : 1
//            titleLabel.isHidden = layerType == .layers
            titleLabel.isHidden = true
//            priceLabel.isHidden = layerType == .layers
            priceLabel.isHidden = true
//            priceSubtitleLabel.isHidden = layerType == .layers
            priceSubtitleLabel.isHidden = true
//            buyButton.isHidden = layerType == .layers
            buyButton.isHidden = true
            selectedBackgroundImageView.isHidden = layerType != .background
            layerBackgroundView.isHidden = layerType == .layers
            
            if layerType == .background {
                buyButton.semanticContentAttribute = .forceRightToLeft
                buyButton.imageEdgeInsets = UIEdgeInsets(top: 0.0, left: 5.0, bottom: 0.0, right: 0.0)
            }
        }
    }
    
    let noneImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(libraryNamed: "empty_layer")
        
        return view
    }()
    
    let layerImageView: UIImageView = {
        let view = UIImageView()
        view.layer.masksToBounds = true
        view.contentMode = .scaleAspectFit
        
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .sfTextSecondary
        label.font = SFPalette.fontMedium.withSize(14)
        label.textAlignment = .center
        
        return label
    }()
    
    let priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .sfTextPrimary
        label.font = SFPalette.fontBold.withSize(16)
        label.textAlignment = .left
        
        return label
    }()
    
    let priceSubtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .sfTextSecondary
        label.font = SFPalette.fontMedium.withSize(14)
        label.textAlignment = .left
        label.text = "$9,8"
        
        return label
    }()
    
    let priceStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .fillProportionally
        
        return view
    }()
        
    let buyButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(libraryNamed: "shoppingCartSmal"), for: .normal)
        button.isHidden = true
        button.setTitleColor(.sfTextPrimary, for: .normal)
        button.titleLabel?.font = SFPalette.fontBold.withSize(12)
        button.imageView?.contentMode = .scaleAspectFit
        
        return button
    }()
    
    let checkmarkImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(libraryNamed: "small_cirle_checkmark")
        view.isHidden = true
        
        return view
    }()
    
    let selectedBackgroundImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.image = nil
        view.clipsToBounds = true
        
        return view
    }()
    
    let layerBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        
        return view
    }()
    
    let skeletonView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isSkeletonable = true
        view.showAnimatedGradientSkeleton(usingGradient: SkeletonGradient(baseColor: .clouds),
                                          transition: .none)
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
                
        contentView.layer.cornerRadius = 16.0
        contentView.layer.borderWidth = 1.0
        contentView.layer.borderColor = UIColor.sfSeparatorLight.cgColor
        contentView.clipsToBounds = true
        
        contentView.addSubview(selectedBackgroundImageView)
        contentView.addSubview(layerBackgroundView)
        contentView.addSubview(layerImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(priceStackView)
        contentView.addSubview(buyButton)
        contentView.addSubview(noneImageView)
        contentView.addSubview(skeletonView)
        contentView.addSubview(checkmarkImageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        contentView.layer.borderColor = UIColor.sfSeparatorLight.cgColor
        buyButton.isHidden = true
        layerImageView.image = nil
        checkmarkImageView.isHidden = true
        priceStackView.removeArrangedSubview(priceSubtitleLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setNeededLayout()
    }
        
    // MARK: Public methods
    
    func setSelected(_ isSelected: Bool) {
        switch layerType {
        case .layers:
            checkmarkImageView.isHidden = !isSelected
            contentView.layer.borderColor = isSelected ?
            UIColor.sfAccentBrand.cgColor :
            UIColor.sfSeparatorLight.cgColor
            
        case .background:
            selectedBackgroundImageView.image = isSelected ? layerImageView.image : nil
            
        case .NFT:
            contentView.layer.borderColor = isSelected ?
            UIColor.sfAccentBrand.cgColor :
            UIColor.sfSeparatorLight.cgColor
        }
    }
    
    func setPrice(_ price: Int?, isPaid: Bool) {
        switch layerType {
        case .NFT:
            priceStackView.addArrangedSubview(priceLabel)
            
            if let price = price {
                if isPaid {
                    priceLabel.text = "commonPaid".libraryLocalized
                    checkmarkImageView.isHidden = false
                    priceSubtitleLabel.isHidden = true
                    buyButton.isHidden = true
                } else {
                    priceLabel.text = "\(price) TON"
                    priceSubtitleLabel.text = "$\(price)"
                    priceSubtitleLabel.isHidden = false
                    checkmarkImageView.isHidden = true
                    buyButton.isHidden = false
                    priceStackView.addArrangedSubview(priceSubtitleLabel)
                }
            } else {
                priceLabel.text = "commonFree".libraryLocalized
                buyButton.isHidden = true
            }
            
        case .background:
            buyButton.setImage(nil, for: .normal)
            if let price = price {
                if isPaid {
                    buyButton.setTitle("commonPaid".libraryLocalized, for: .normal)
                } else {
                    buyButton.setImage(UIImage(libraryNamed: "shoppingCartSmal"), for: .normal)
                    buyButton.setTitle("\(price) TON", for: .normal)
                }
            } else {
                buyButton.setTitle("commonFree".libraryLocalized, for: .normal)
            }
            
        case .layers:
            break
        }
        
        layoutIfNeeded()
    }
    
    // MARK: Private methods
        
    private func setNeededLayout() {
        switch layerType {
        case .layers: layersLayout()
        case .background: backgroundLayout()
        case .NFT: NFTLayout()
        }
        
        skeletonView.pin
            .all()
    }
    
    private func layersLayout() {
        layerImageView.layer.cornerRadius = 0.0
        
        noneImageView.pin
            .center()
            .size(40)
        
        layerImageView.pin.all()
        
        checkmarkImageView.pin
            .bottom(12.0)
            .right(12.0)
            .size(18.0)
    }
    
    private func backgroundLayout() {
        selectedBackgroundImageView.pin
            .top()
            .left()
            .right()
        selectedBackgroundImageView.pin
            .height(selectedBackgroundImageView.frame.width)
        selectedBackgroundImageView.layer.cornerRadius = selectedBackgroundImageView.frame.width / 2
        
        layerBackgroundView.pin
            .top(4.0)
            .left(4.0)
            .right(4.0)
        layerBackgroundView.pin
            .height(layerBackgroundView.frame.width)
        layerBackgroundView.layer.cornerRadius = layerBackgroundView.frame.width / 2
        
        layerImageView.pin
            .top(12.0)
            .left(12.0)
            .right(12.0)
        layerImageView.pin
            .height(layerImageView.frame.width)
        layerImageView.layer.cornerRadius = layerImageView.frame.width / 2
        
        titleLabel.pin
            .left()
            .right()
            .top(to: layerBackgroundView.edge.bottom).marginTop(8.3)
            .sizeToFit(.width)
        
        if buyButton.isHidden {
            priceLabel.pin
                .left()
                .right()
                .top(to: titleLabel.edge.bottom).marginTop(4.0)
                .sizeToFit(.width)
        } else {
            buyButton.pin
                .left()
                .right()
                .height(20.0)
//                .top(to: titleLabel.edge.bottom).marginTop(4.0)
                .bottom()
        }
        
    }
    
    private func NFTLayout() {
        layerImageView.pin
            .top(24.0)
            .left(24.0)
            .right(24.0)
            .height(67.0)
        
        titleLabel.pin
            .top(to: layerImageView.edge.bottom).marginTop(12.0)
            .left()
            .right()
            .sizeToFit(.width)
        
        buyButton.pin
            .right(12.0)
            .size(24.0)
            .bottom(12.0)
        
        checkmarkImageView.pin
            .right(12.0)
            .size(18.0)
            .bottom(12.0)
        
        priceStackView.pin
            .bottom(12.0)
            .left(12.0)
            .right(36.0)
            .height(CGFloat(priceStackView.arrangedSubviews.count) * 20.0)
    }
    
}
