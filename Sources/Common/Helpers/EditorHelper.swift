import Alamofire
import Foundation

public class EditorHelper {
    public typealias ResultLayers = (removedLayer: String, layers: String)
    
    static let shared = EditorHelper()
    
    private let provider = StickerFaceEditorProvider()
    private var isLoading = false
    private(set) var editor: Editor?
    
    // MARK: - SDK Methods
    
    public func removeLayer(in subsection: String, from layers: String) -> ResultLayers {
        guard let editor = editor else { return ResultLayers("", "") }
        
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
            if let subsectionLayers = allObjectSubsections.first(where: { $0.name.lowercased() == subsection.lowercased() })?.layers {
                allLayers.enumerated().forEach { index, layer in
                    if subsectionLayers.contains(layer) {
                        deleteIndex = index
                    }
                }
            }
        } else {
            if let subsectionLayers = allManSubsecitons.first(where: { $0.name.lowercased() == subsection.lowercased() })?.layers {
                allLayers.enumerated().forEach { index, layer in
                    if subsectionLayers.contains(layer) {
                        deleteIndex = index
                    }
                }
            }
        }
        
        var removedLayer = ""
        var resultLayers = ""
        
        if let index = deleteIndex {
            removedLayer = allLayers.remove(at: index)
        }
        
        resultLayers = allLayers.joined(separator: ";")
        
        return ResultLayers(removedLayer, resultLayers)
    }
    
    // MARK: - Public mehtods
    
    func loadEditor(for owner: String? = SFDefaults.tonClient?.address) {
        guard !isLoading else { return }
        
        provider.loadEditor { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let editor):
                SFDefaults.avatarCollection = editor.nft.avatarCollection
                SFDefaults.wearablesCollection = editor.nft.wearablesCollection
                SFDefaults.avatarMintPrice = Double(editor.nft.avatarMintPrice) / 1000000000.0
                self.editor = editor
                self.loadWardrobe(for: owner)
                
            case .failure(let error):
                print("EditorHelper: 😡 Error: loadEditor() - \(error)")
                
                self.isLoading = false
                
                let userInfo = ["error": error]
                let name = Notification.Name("editorDidLoaded")
                NotificationCenter.default.post(name: name, object: nil, userInfo: userInfo)
            }
        }
    }
    
    func reloadEditor(for owner: String? = SFDefaults.tonClient?.address) {
        editor = nil
        loadEditor(for: owner)
    }
    
    func loadWardrobe(for owner: String?) {
        provider.loadWardrobe(owner: owner, onSale: true, offset: 0) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let wardrobe):
                guard var editor = self.editor else { return }
                
                let metadata = wardrobe.nftItems?.compactMap({ $0.metadata })
                metadata?.forEach { data in
                    guard
                        let section = data.attributes?.first(where: { $0.traitType == .section })?.value,
                        let nftLayer = data.attributes?.first(where: { $0.traitType == .layer })?.value
                    else { return }
                    
                    let layer = nftLayer.components(separatedBy: ";").joined(separator: ",")
                    let subsection = section
                    
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
                
                self.isLoading = false
                self.editor = editor
                
                let name = Notification.Name("editorDidLoaded")
                NotificationCenter.default.post(name: name, object: nil, userInfo: nil)
            
            case .failure(let error):
                print("EditorHelper: 😡 Error: loadWardrobe() - \(error)")
                
                self.isLoading = false
                
                let userInfo = ["error": error]
                let name = Notification.Name("editorDidLoaded")
                NotificationCenter.default.post(name: name, object: nil, userInfo: userInfo)
            }
        }
    }
}
