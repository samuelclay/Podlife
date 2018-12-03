//
//  PodSelection.swift
//  ARKitInteraction
//
//  Created by Samuel Clay on 12/2/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import Foundation
import UIKit

class PodSelectionCell : UICollectionViewCell {
    static let reuseIdentifier = "PodSelectionCell"
    
    @IBOutlet weak var podSelectionLabel: UILabel!
    @IBOutlet weak var podSelectionImage: UIImageView!
    @IBOutlet weak var vibrancyView: UIVisualEffectView!
    
    var modelName = "" {
        didSet {
            podSelectionLabel.text = modelName
            podSelectionImage.image = UIImage(named: modelName)
        }
    }
}

protocol PodSelectionCollectionViewControllerDelegate: class {
    func podSelectionCollectionViewController(_ selectionViewController: PodSelectionCollectionViewController,
                                              didSelectObject: VirtualObject)
}

class PodSelectionCollectionViewController : UICollectionViewController {
    
    var virtualObjects = [VirtualObject]()
    var selectedVirtualObjectRow: Int?
    weak var delegate: PodSelectionCollectionViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return virtualObjects.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PodSelectionCell.reuseIdentifier, for: indexPath) as? PodSelectionCell else {
            fatalError("Expected `\(PodSelectionCell.self)` type for reuseIdentifier \(PodSelectionCell.reuseIdentifier). Check the configuration in Main.storyboard.")
        }
        
        cell.modelName = virtualObjects[indexPath.row].modelName
        
        if selectedVirtualObjectRow == indexPath.row {
            cell.vibrancyView.alpha = 1.0
        } else {
            cell.vibrancyView.alpha = 0.1
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedVirtualObjectRow = indexPath.row
        delegate?.podSelectionCollectionViewController(self, didSelectObject: virtualObjects[indexPath.row])
    }
    
}
