import UIKit

class PresentHeaderView: UIView {

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 48.0)
    }
    
    let closeButton: UIButton = {
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(libraryNamed: "close_28")?.withRenderingMode(.alwaysTemplate), for: .normal)
        closeButton.tintColor = .sfAccentBrand
        
        return closeButton
    }()
    
    let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "inviteContactsShare".libraryLocalized
        titleLabel.font = Palette.fontBold.withSize(20.0)
        titleLabel.textColor = .black
        
        return titleLabel
    }()
    
    init(title: String) {
        super.init(frame: .zero)
        
        titleLabel.text = title
        
        addSubview(closeButton)
        addSubview(titleLabel)
        
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        closeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12.0)
            make.leading.equalToSuperview().offset(18.0)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
    }

}
