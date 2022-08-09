import UIKit

class EditorSectionHeaderCell: UICollectionViewCell {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .sfTextSecondary
        label.font = SFPalette.fontMedium.withSize(15.0)
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16.0)
            make.right.equalToSuperview().offset(-20)
            make.bottom.left.equalToSuperview()
        }
    }
    
}
