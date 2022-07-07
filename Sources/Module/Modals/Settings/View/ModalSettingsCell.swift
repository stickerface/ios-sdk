import UIKit

class ModalSettingsCell: UITableViewCell {

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = SFPalette.fontMedium.withSize(16.0)
        label.textColor = .sfAccentSecondary
        
        return label
    }()
    
    let rightImageView: UIImageView = {
        let view = UIImageView()
        
        return view
    }()
    
    let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .sfSeparatorLight
        
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(rightImageView)
        contentView.addSubview(separatorView)
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16.0)
        }
        
        rightImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16.0)
            make.centerY.equalToSuperview()
            make.size.equalTo(24.0)
        }
        
        separatorView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(16.0)
            make.right.equalToSuperview().offset(-16.0)
            make.height.equalTo(1.0)
        }
    }
}
