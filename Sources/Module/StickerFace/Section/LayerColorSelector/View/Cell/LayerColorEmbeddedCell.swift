import UIKit
import PinLayout

class LayerColorEmbeddedCell: UICollectionViewCell {
    
//    let colorSelectionIndicatorView: UIImageView = {
//        let imageView = UIImageView(image: UIImage(libraryNamed: "colorSelectionIndicator"))
//        imageView.isHidden = true
//
//        return imageView
//    }()
        
    let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20.5
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
                
        contentView.addSubview(colorView)
//        contentView.addSubview(colorSelectionIndicatorView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layout()
    }
    
    private func layout() {
        colorView.pin.center().size(41.0)
//        colorSelectionIndicatorView.pin.center(to: colorView.anchor.center).size(50.0)
    }
    
}
