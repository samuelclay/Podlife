/*
See LICENSE folder for this sample’s licensing information.

Abstract:
UI Actions for the main view controller.
*/

import UIKit
import SceneKit

extension ViewController: UIGestureRecognizerDelegate {
    

    
    enum SegueIdentifier: String {
        case showObjects
    }
    
    // MARK: - Interface Actions
    
    /// Displays the `VirtualObjectSelectionViewController` from the `addObjectButton` or in response to a tap gesture in the `sceneView`.
    @IBAction func showVirtualObjectSelectionViewController() {
        // Ensure adding objects is an available action and we are not loading another object (to avoid concurrent modifications of the scene).
        guard !addObjectButton.isHidden && !virtualObjectLoader.isLoading else { return }
        
        statusViewController.cancelScheduledMessage(for: .contentPlacement)
//        performSegue(withIdentifier: SegueIdentifier.showObjects.rawValue, sender: addObjectButton)
    }
    
    /// Determines if the tap gesture for presenting the `VirtualObjectSelectionViewController` should be used.
    func gestureRecognizerShouldBegin(_: UIGestureRecognizer) -> Bool {
        return virtualObjectLoader.loadedObjects.isEmpty
    }
    
    func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer) -> Bool {
        return true
    }
    
    /// - Tag: restartExperience
    func restartExperience() {
        guard isRestartAvailable, !virtualObjectLoader.isLoading else { return }
        isRestartAvailable = false

        statusViewController.cancelAllScheduledMessages()

        self.resetNetworkDiagram()
        virtualObjectInteraction.resetDoor()

        virtualObjectLoader.removeAllVirtualObjects()
        addObjectButton.setImage(#imageLiteral(resourceName: "add"), for: [])
        addObjectButton.setImage(#imageLiteral(resourceName: "addPressed"), for: [.highlighted])

        resetTracking()

        // Disable restart for a while in order to give the session time to restart.
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.isRestartAvailable = true
        }
    }
    
    func toggleNetworkDiagram() {
        isNetworkDiagramVisible = !isNetworkDiagramVisible
        
        if isNetworkDiagramVisible {
            self.drawNetworkDiagram()
        } else {
            self.scalePod()
            self.removeNetworkDiagram()
            self.podSelectionViewController.view.alpha = 1
        }
    }
    
    func drawNetworkDiagram() {
        if let object = VirtualObject.availableObjects.first(where: { (model) -> Bool in
            print("\(model.modelName): \(String(describing: model.modelName.range(of: "Network")))")
            return model.modelName.range(of: "NetworkDiagramRoute\(self.currentNetworkDiagram+1)") != nil
        }) {
            self.scalePod()
            virtualObjectLoader.loadVirtualObject(object, loadedHandler: { [unowned self] loadedObject in
                self.sceneView.prepare([object], completionHandler: { _ in
                    DispatchQueue.main.async {
                        self.hideObjectLoadingUI()
                        
                        if let parentObject = self.virtualObjectLoader.loadedObjects.first(where: { (object) -> Bool in
                            return object.modelName.range(of: "Network") == nil
                        })
                            //                                let mapBase = parentObject.childNode(withName: "MapBase", recursively: true)
                        {
                            loadedObject.opacity = 0
                            self.placeVirtualObject(loadedObject, in: parentObject)
                            SCNTransaction.animationDuration = 3
                            loadedObject.opacity = 1
                        } else {
                            self.placeVirtualObject(loadedObject)
                        }
                        loadedObject.isHidden = false
                        self.podSelectionViewController.view.alpha = 0
                    }
                })
            })
        }
    }
    
    func removeNetworkDiagram() {
        if let object = virtualObjectLoader.loadedObjects.first(where: { (model) -> Bool in
            print("\(model.modelName): \(String(describing: model.modelName.range(of: "Network")))")
            return model.modelName.range(of: "Network") != nil
        }) {
            virtualObjectLoader.removeVirtualObject(object)
        }
    }
    
    func scalePod() {
        guard let podObject = virtualObjectLoader.loadedObjects.first(where: { (object) -> Bool in
            return object.modelName.range(of: "Network") == nil
        }) else {
            return
        }
        if let podObjectWithoutMap = podObject.childNode(withName: "pod", recursively: true) {
            SCNTransaction.animationDuration = 3

            if isNetworkDiagramVisible {
                podObject.rotation = SCNVector4(0, 1, 0, Double.pi/2)
//                podObject.position = SCNVector3(0, 0, 0)
                podObjectWithoutMap.scale = SCNVector3(0.001, 0.001, 0.001)
            } else {
                podObject.rotation = SCNVector4(0, 0, 0, Double.pi/2)
//                podObject.position = SCNVector3(0, 0, 0)
                podObjectWithoutMap.scale = SCNVector3(0.01, 0.01, 0.01)
            }
        }
    }
    
    func nextNetworkDiagram() {
        currentNetworkDiagram = (currentNetworkDiagram + 1) % 3
        
        self.removeNetworkDiagram()
        self.drawNetworkDiagram()
    }
    
    func resetNetworkDiagram() {
        isNetworkDiagramVisible = true
        self.scalePod()
        self.removeNetworkDiagram()
        isNetworkDiagramVisible = false
        self.podSelectionViewController.view.alpha = 1
    }

}

extension ViewController: UIPopoverPresentationControllerDelegate {
    
    // MARK: - UIPopoverPresentationControllerDelegate

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // All menus should be popovers (even on iPhone).
        if let popoverController = segue.destination.popoverPresentationController, let button = sender as? UIButton {
            popoverController.delegate = self
            popoverController.sourceView = button
            popoverController.sourceRect = button.bounds
        }
        
        guard let identifier = segue.identifier,
              let segueIdentifer = SegueIdentifier(rawValue: identifier),
              segueIdentifer == .showObjects else { return }
        
        let objectsViewController = segue.destination as! VirtualObjectSelectionViewController
        objectsViewController.virtualObjects = VirtualObject.availableObjects
        objectsViewController.delegate = self
        self.objectsViewController = objectsViewController
        
        // Set all rows of currently placed objects to selected.
        for object in virtualObjectLoader.loadedObjects {
            guard let index = VirtualObject.availableObjects.index(of: object) else { continue }
            objectsViewController.selectedVirtualObjectRows.insert(index)
        }
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        objectsViewController = nil
    }
}
