import UIKit
import PinLayout
import SkeletonView

class EditorLayerCollectionCell: UICollectionViewCell {
    
    enum CellType {
        case layers
        case background
        case NFT
    }
    
    var cellType: CellType = .layers {
        didSet {
            contentView.layer.borderWidth = cellType == .background ? 0 : 1
            titleLabel.isHidden = cellType == .layers ? true : false
            priceLabel.isHidden = cellType == .layers ? true : false
            subtitlePriceLabel.isHidden = cellType == .layers ? true : false
            buyButton.isHidden = cellType == .layers ? true : false
            selectedBackgroundImageView.isHidden = cellType == .background ? false : true
            layerBackgroundView.isHidden = cellType == .layers ? true : false
            
            if cellType == .background {
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
        label.font = Palette.fontMedium.withSize(14)
        label.textAlignment = .center
        
        return label
    }()
    
    let priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .sfTextPrimary
        label.font = Palette.fontBold.withSize(16)
        label.textAlignment = .center
        
        return label
    }()
    
    let subtitlePriceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .sfTextSecondary
        label.font = Palette.fontMedium.withSize(14)
        label.textAlignment = .left
        label.text = "$9,8"
        
        return label
    }()
        
    let buyButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(libraryNamed: "shoppingCartSmal"), for: .normal)
        button.isHidden = true
        button.setTitleColor(.sfTextPrimary, for: .normal)
        button.titleLabel?.font = Palette.fontBold.withSize(12)
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
        view.layer.cornerRadius = 50.0
        view.contentMode = .scaleAspectFill
        view.image = nil
        view.clipsToBounds = true
        
        return view
    }()
    
    let layerBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 45.5
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
                
        contentView.layer.cornerRadius = 16.0
        contentView.layer.borderWidth = 1.0
        contentView.layer.borderColor = UIColor.sfSeparatorLight.cgColor
        contentView.clipsToBounds = true
        contentView.isSkeletonable = true
        
        contentView.addSubview(selectedBackgroundImageView)
        contentView.addSubview(layerBackgroundView)
        contentView.addSubview(layerImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(subtitlePriceLabel)
        contentView.addSubview(buyButton)
        contentView.addSubview(checkmarkImageView)
        contentView.addSubview(noneImageView)
        
        contentView.showSkeleton()
        contentView.startSkeletonAnimation()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        buyButton.isHidden = true
        priceLabel.isHidden = true
        noneImageView.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setNeededLayout()
    }
        
    // MARK: Public methods
    
    func setSelected(_ isSelected: Bool) {
        switch cellType {
        case .layers:
            checkmarkImageView.isHidden = !isSelected
            contentView.layer.borderColor = isSelected ?
            UIColor.sfAccentBrand.cgColor :
            UIColor.sfSeparatorLight.cgColor
            
        case .background:
            selectedBackgroundImageView.image = isSelected ? layerImageView.image : nil
            
        case .NFT:
            break
        }
        
    }
    
    func setPrice(_ price: Int) {
        switch cellType {
        case .layers, .NFT:
            priceLabel.isHidden = false
            priceLabel.text = "\(price) TON"
        case .background:
            priceLabel.isHidden = true
            buyButton.setTitle("\(price) TON", for: .normal)
        }
    }
    
    // MARK: Private methods
        
    private func setNeededLayout() {
        switch cellType {
        case .layers:
            layersLayout()
            
        case .background:
            backgroundLayout()
            
        case .NFT:
            NFTLayout()
        }
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
        layerImageView.layer.cornerRadius = 38.5
        
        selectedBackgroundImageView.pin
            .top()
            .hCenter()
            .size(100.0)
        
        layerBackgroundView.pin
            .top(4.5)
            .hCenter()
            .size(91.0)
        
        layerImageView.pin
            .size(77.0)
            .hCenter(to: layerBackgroundView.edge.hCenter)
            .vCenter(to: layerBackgroundView.edge.vCenter)
        
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
            .top(to: titleLabel.edge.bottom).marginTop(29.0)
            .size(24.0)
            .bottom()
        
        priceLabel.pin
            .top(to: titleLabel.edge.bottom).marginTop(13.0)
            .left(12.0)
            .sizeToFit(.widthFlexible)
        
        subtitlePriceLabel.pin
            .top(to: priceLabel.edge.bottom)
            .left(12.0)
            .sizeToFit(.widthFlexible)
    }
    
}
