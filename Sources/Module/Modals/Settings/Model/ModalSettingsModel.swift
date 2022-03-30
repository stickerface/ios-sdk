import UIKit

typealias Action = () -> ()

struct ModalSettingsModel {
    let title: String
    let image: UIImage?
    let action: Action
}
