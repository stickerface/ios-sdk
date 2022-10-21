import Alamofire
import Foundation

class EditorHelper {
    
    static let shared = EditorHelper()
    
    private let provider = StickerFaceEditorProvider()
    private var editor: Editor?
    
    // MARK: - Public mehtods
    
    func loadEditor() {
        provider.loadEditor { result in
            switch result {
            case .success(let editor):
                SFDefaults.avatarCollection = editor.nft.avatarCollection
                SFDefaults.wearablesCollection = editor.nft.wearablesCollection
                SFDefaults.avatarMintPrice = Double(editor.nft.avatarMintPrice) / 1000000000.0
                self.editor = editor
                self.loadWardrobe()
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func removeLayer(in subsection: String, from layers: String) -> String {
        guard let editor = editor else { fatalError("need load editor first") }
        
        var layers = layers
        
        if let range = layers.range(of: "/") {
            layers.removeSubrange(range.lowerBound..<layers.endIndex)
        }
        
        var allLayers = layers.components(separatedBy: ";").compactMap { layer -> String? in
            return layer != "" ? layer : nil
        }
        
        let allManSubsecitons = editor.sections.man.flatMap { $0.subsections }
        let allObjectSubsections = editor.sections.woman.flatMap { $0.subsections }
        var deleteIndex: Int?
        
        if allLayers.contains("0") && allLayers.contains("25") {
            if let subsectionLayers = allObjectSubsections.first(where: { $0.name == subsection })?.layers {
                allLayers.enumerated().forEach { index, layer in
                    if subsectionLayers.contains(layer) {
                        deleteIndex = index
                    }
                }
            }
        } else {
            if let subsectionLayers = allManSubsecitons.first(where: { $0.name == subsection })?.layers {
                allLayers.enumerated().forEach { index, layer in
                    if subsectionLayers.contains(layer) {
                        deleteIndex = index
                    }
                }
            }
        }
        
        if let index = deleteIndex {
            allLayers.remove(at: index)
        }
        
        return allLayers.joined(separator: ";")
    }
    
    func loadWardrobe(owner: String? = SFDefaults.tonClient?.address) {
        provider.loadWardrobe(owner: owner, onSale: true, offset: 0) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let wardrobe):
                guard var editor = self.editor else { return }
                
                let metadata = wardrobe.nftItems?.compactMap({ $0.metadata })
                metadata?.forEach { data in
                    guard
                        let section = data.attributes?.first(where: { $0.traitType == .section })?.value,
                        let subsection = data.attributes?.first(where: { $0.traitType == .subsection })?.value,
                        let layer = data.attributes?.first(where: { $0.traitType == .layer })?.value
                    else { return }
                    
                    let manSections = editor.sections.man
                    let sectionIndex = manSections.firstIndex(where: { $0.name.lowercased() == section.lowercased() })
                    
                    let womenSections = editor.sections.woman
                    let wSectionIndex = womenSections.firstIndex(where: { $0.name.lowercased() == section.lowercased() })
                    
                    if let sectionIndex = sectionIndex {
                        var subsections = manSections[sectionIndex].subsections
                        let subsectionIndex = subsections.firstIndex(where: { $0.name.lowercased() == subsection.lowercased() })
                        
                        if let subsectionIndex = subsectionIndex {
                            if subsections[subsectionIndex].layers?.contains(layer) == false {
                                subsections[subsectionIndex].layers?.insert(layer, at: 0)
                            }
                        } else {
                            let subsection = EditorSubsection(name: subsection, layers: [layer, "0"], colors: nil)
                            subsections.append(subsection)
                        }
                        
                        editor.sections.man[sectionIndex].subsections = subsections
                    } else {
                        let subsections = EditorSubsection(name: subsection, layers: [layer, "0"], colors: nil)
                        let section = EditorSection(name: section, subsections: [subsections])
                        editor.sections.man.append(section)
                    }
                    
                    if let sectionIndex = wSectionIndex {
                        var subsections = womenSections[sectionIndex].subsections
                        let subsectionIndex = subsections.firstIndex(where: { $0.name.lowercased() == subsection.lowercased() })
                        
                        if let subsectionIndex = subsectionIndex {
                            if subsections[subsectionIndex].layers?.contains(layer) == false {
                                subsections[subsectionIndex].layers?.insert(layer, at: 0)
                            }
                        } else {
                            let subsection = EditorSubsection(name: subsection, layers: [layer, "0"], colors: nil)
                            subsections.append(subsection)
                        }
                        
                        editor.sections.woman[sectionIndex].subsections = subsections
                    } else {
                        let subsections = EditorSubsection(name: subsection, layers: [layer, "0"], colors: nil)
                        let section = EditorSection(name: section, subsections: [subsections])
                        editor.sections.woman.append(section)
                    }
                }
                
                self.editor = editor
            
            case .failure(let error):
                print(error)
            }
        }
    }
}
