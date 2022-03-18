import Foundation

extension CGSize {

    var widthToHeightRatio: CGFloat {
        return self.width / self.height
    }

    var heightToWidthRatio: CGFloat {
        return self.height / self.width
    }

    var maxSide: CGFloat {
        return max(self.width, self.height)
    }

    var minSide: CGFloat {
        return min(self.width, self.height)
    }

    init(side: CGFloat) {
        self.init(width: side, height: side)
    }
    
}
