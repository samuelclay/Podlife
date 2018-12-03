//
//  ViewController+PodSelection.swift
//  ARKitInteraction
//
//  Created by Samuel Clay on 12/2/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import ARKit

extension ViewController: PodSelectionCollectionViewControllerDelegate {
    
    // MARK: - VirtualObjectSelectionViewControllerDelegate
    
    func podSelectionCollectionViewController(_: PodSelectionCollectionViewController, didSelectObject object: VirtualObject) {
        virtualObjectLoader.removeAllVirtualObjects()
        
        virtualObjectLoader.loadVirtualObject(object, loadedHandler: { [unowned self] loadedObject in
            self.sceneView.prepare([object], completionHandler: { _ in
                DispatchQueue.main.async {
                    self.hideObjectLoadingUI()
                    self.placeVirtualObject(loadedObject)
                    loadedObject.isHidden = false
                }
            })
        })
        
        displayObjectLoadingUI()
    }
    
}
