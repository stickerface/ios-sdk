import UIKit

typealias Action = () -> ()

struct ModalSettingsCellModel {
    let title: String
    let image: UIImage?
    let action: Action
}
