import UIKit
import IGListKit

protocol StickersSectionControllerDelegate: AnyObject {
    func stickersSectionController(didSelect sticker: UIImage?)
}

class StickerFaceMainStickersSectionController: ListSectionController {
    
    var sticker: StickerFaceMainSticker!
    weak var delegate: StickersSectionControllerDelegate?
    
    override init() {
        super.init()
        
        inset = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 116.0, right: 16.0)
        minimumInteritemSpacing = 12.0
        minimumLineSpacing = 12.0
        supplementaryViewSource = self
    }
    
    override func didUpdate(to object: Any) {
        precondition(object is StickerFaceMainSticker)
        sticker = object as? StickerFaceMainSticker
    }
    
    override func didSelectItem(at index: Int) {
        if let cell = collectionContext?.cellForItem(at: index, sectionController: self) as? StickerFaceMainStickersCell {
            delegate?.stickersSectionController(didSelect: cell.imageView.image)
        }
    }
    
    override func numberOfItems() -> Int {
        return 29
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(side: (collectionContext!.insetContainerSize.width - 16 - 12 - 16)/2)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeue(of: StickerFaceMainStickersCell.self, for: self, at: index)
        
        let layers = "s\(index + 1);" + sticker.layers
        ImageLoader.setAvatar(with: layers, backgroundColor: .clear, for: cell.imageView, side: 248, cornerRadius: 0)
        
        return cell
    }
    
}

// MARK: - ListSupplementaryViewSource
extension StickerFaceMainStickersSectionController: ListSupplementaryViewSource {
    
    func supportedElementKinds() -> [String] {
        return [UICollectionElementKindSectionHeader]
    }
    
    func viewForSupplementaryElement(ofKind elementKind: String, at index: Int) -> UICollectionReusableView {
        let view = collectionContext!.dequeue(ofKind: UICollectionElementKindSectionHeader, for: self, of: StickerFaceMainStickersHeaderView.self, at: index)
        view.titleLabel.text = "mainStickers".libraryLocalized
        
        return view
    }
    
    func sizeForSupplementaryView(ofKind elementKind: String, at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width, height: 46.0)
    }
    
}
