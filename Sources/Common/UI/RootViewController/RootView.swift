import UIKit

public class RootView: UIView {
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    func setup() {
        
    }
    
    func didLoad() {
        
    }
    
    func willAppear() {
        
    }
    
    func willDisappear() {
        
    }
    
    func didAppear() {
        
    }
    
    func didDisappear() {
        
    }
}
