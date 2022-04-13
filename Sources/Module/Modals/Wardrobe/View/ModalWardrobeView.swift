import UIKit

class ModalWardrobeView: RootView {

    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Wardrobe"
        label.font = Palette.fontBold.withSize(20)
        label.textColor = .sfAccentSecondary
        label.textAlignment = .center
        
        return label
    }()
    
    let emptyView: ModalWardrobeEmptyView = {
        let view = ModalWardrobeEmptyView()
        
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
        containerView.addSubview(emptyView)
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
        
        emptyView.pin
            .top(to: titleLabel.edge.bottom)
            .height(428.0)
            .left()
            .right()
        
        bottomView.pin
            .top(to: emptyView.edge.bottom)
            .left()
            .right()
            .height(UIScreen.main.bounds.height)
        
        containerView.pin
            .height(emptyView.frame.maxY + Utils.safeArea().bottom)
        
        pin.height(bottomView.frame.maxY)
    }
    
}
