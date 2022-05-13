import UIKit
import WebKit

class StickerFaceEditorPageView: RootView {
    
    let renderWebView: WKWebView = {
        let webView = WKWebView()
        webView.alpha = 0
        
        return webView
    }()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.contentInset = UIEdgeInsets(top: 12.0, left: 16.0, bottom: 116.0, right: 16.0)
        view.alwaysBounceVertical = true
        view.showsVerticalScrollIndicator = false
        view.backgroundColor = .clear
        
        return view
    }()
    
    override func setup() {
        backgroundColor = .clear

        addSubview(renderWebView)
        addSubview(collectionView)
        
        setupConstraints()
    }

    private func setupConstraints() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        renderWebView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(166.0)
            make.height.equalTo(188.0)
        }
    }
    
}
