import UIKit

@available(iOS 14, *)
extension UIVisualEffectView {
    var ios14_blurRadius: CGFloat {
        get {
            return gaussianBlur?.requestedValues?[/*inputRadius*/"aW5wdXRSYWRpdXM=".base64Decoded()!] as? CGFloat ?? 0
        }
        set {
            prepareForChanges()
            gaussianBlur?.requestedValues?[/*inputRadius*/"aW5wdXRSYWRpdXM=".base64Decoded()!] = newValue
            applyChanges()
        }
    }
    var ios14_colorTint: UIColor? {
        get {
            return sourceOver?.value(forKeyPath: /*color*/"Y29sb3I=".base64Decoded()!) as? UIColor
        }
        set {
            prepareForChanges()
            sourceOver?.setValue(newValue, forKeyPath: /*color*/"Y29sb3I=".base64Decoded()!)
            sourceOver?.perform(Selector((/*applyRequestedEffectToView:*/"YXBwbHlSZXF1ZXN0ZWRFZmZlY3RUb1ZpZXc6".base64Decoded()!)), with: overlayView)
            applyChanges()
        }
    }
}

private extension UIVisualEffectView {
    var backdropView: UIView? {
        return subview(of: NSClassFromString(/*_UIVisualEffectBackdropView*/"X1VJVmlzdWFsRWZmZWN0QmFja2Ryb3BWaWV3".base64Decoded()!))
    }
    var overlayView: UIView? {
        return subview(of: NSClassFromString(/*_UIVisualEffectSubview*/"X1VJVmlzdWFsRWZmZWN0U3Vidmlldw==".base64Decoded()!))
    }
    var gaussianBlur: NSObject? {
        return backdropView?.value(forKey: /*filters*/"ZmlsdGVycw==".base64Decoded()!, withFilterType: /*gaussianBlur*/"Z2F1c3NpYW5CbHVy".base64Decoded()!)
    }
    var sourceOver: NSObject? {
        return overlayView?.value(forKey: /*viewEffects*/"dmlld0VmZmVjdHM=".base64Decoded()!, withFilterType: /*sourceOver*/"c291cmNlT3Zlcg==".base64Decoded()!)
    }
    func prepareForChanges() {
        self.effect = UIBlurEffect(style: .light)
        gaussianBlur?.setValue(1.0, forKeyPath: /*requestedScaleHint*/"cmVxdWVzdGVkU2NhbGVIaW50".base64Decoded()!)
    }
    func applyChanges() {
        backdropView?.perform(Selector((/*applyRequestedFilterEffects*/"YXBwbHlSZXF1ZXN0ZWRGaWx0ZXJFZmZlY3Rz".base64Decoded()!)))
    }
}

private extension NSObject {
    var requestedValues: [String: Any]? {
        get { return value(forKeyPath: /*requestedValues*/"cmVxdWVzdGVkVmFsdWVz".base64Decoded()!) as? [String: Any] }
        set { setValue(newValue, forKeyPath: /*requestedValues*/"cmVxdWVzdGVkVmFsdWVz".base64Decoded()!) }
    }
    func value(forKey key: String, withFilterType filterType: String) -> NSObject? {
        return (value(forKeyPath: key) as? [NSObject])?.first { $0.value(forKeyPath: /*filterType*/"ZmlsdGVyVHlwZQ==".base64Decoded()!) as? String == filterType }
    }
}

private extension UIView {
    func subview(of classType: AnyClass?) -> UIView? {
        return subviews.first { type(of: $0) == classType }
    }
}

open class VisualEffectView: UIVisualEffectView {
    
    /// Returns the instance of UIBlurEffect.
    private let blurEffect: UIBlurEffect? = {
        guard let className = /*_UICustomBlurEffect*/"X1VJQ3VzdG9tQmx1ckVmZmVjdA==".base64Decoded() else {
            return nil
        }
        
        return (NSClassFromString(className) as? UIBlurEffect.Type)?.init()
    }()
    
    /**
     Tint color.
     
     The default value is nil.
     */
    open var colorTint: UIColor? {
        get {
            if #available(iOS 14, *) {
                return ios14_colorTint
            } else {
                return _value(forKey: /*colorTint*/"Y29sb3JUaW50".base64Decoded()) as? UIColor
            }
        }
        set {
            if #available(iOS 14, *) {
                ios14_colorTint = newValue
            } else {
                _setValue(newValue, forKey: /*colorTint*/"Y29sb3JUaW50".base64Decoded())
            }
        }
    }
    
    /**
     Tint color alpha.
     
     The default value is 0.0.
     */
    open var colorTintAlpha: CGFloat {
        get {
            return _value(forKey: /*colorTintAlpha*/"Y29sb3JUaW50QWxwaGE=".base64Decoded()) as? CGFloat ?? 0.0
        }
        set {
            if #available(iOS 14, *) {
                ios14_colorTint = ios14_colorTint?.withAlphaComponent(newValue)
            } else {
                _setValue(newValue, forKey: /*colorTintAlpha*/"Y29sb3JUaW50QWxwaGE=".base64Decoded())
            }
        }
    }
    
    /**
     Blur radius.
     
     The default value is 0.0.
     */
    open var blurRadius: CGFloat {
        get {
            if #available(iOS 14, *) {
                return ios14_blurRadius
            } else {
                return _value(forKey: /*blurRadius*/"Ymx1clJhZGl1cw==".base64Decoded()) as? CGFloat ?? 0.0
            }
        }
        set {
            if #available(iOS 14, *) {
                ios14_blurRadius = newValue
            } else {
                _setValue(newValue, forKey: /*blurRadius*/"Ymx1clJhZGl1cw==".base64Decoded())
            }
        }
    }
    
    /**
     Scale factor.
     
     The scale factor determines how content in the view is mapped from the logical coordinate space (measured in points) to the device coordinate space (measured in pixels).
     
     The default value is 1.0.
     */
    open var scale: CGFloat {
        get { return _value(forKey: /*scale*/"c2NhbGU=".base64Decoded()) as? CGFloat ?? 1.0 }
        set { _setValue(newValue, forKey: /*scale*/"c2NhbGU=".base64Decoded()) }
    }
    
    // MARK: - Initialization
    
    public override init(effect: UIVisualEffect?) {
        super.init(effect: effect)
        
        scale = 1
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        scale = 1
    }
    
}

// MARK: - Helpers

private extension VisualEffectView {
    
    /// Returns the value for the key on the blurEffect.
    func _value(forKey key: String?) -> Any? {
        guard let key = key else {
            return nil
        }
        
        return blurEffect?.value(forKeyPath: key)
    }
    
    /// Sets the value for the key on the blurEffect.
    func _setValue(_ value: Any?, forKey key: String?) {
        guard let key = key else {
            return
        }
        
        blurEffect?.setValue(value, forKeyPath: key)
        
        if #available(iOS 14, *) {} else {
            self.effect = blurEffect
        }
    }
    
}
