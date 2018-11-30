//
//  ViewController.swift
//  Podlife
//
//  Created by Samuel Clay on 11/28/18.
//  Copyright © 2018 Podlife. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var didInitializeScene: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapScreen))
        self.view.addGestureRecognizer(tapRecognizer)
        
        
//        sceneView.autoenablesDefaultLighting = false;
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    @objc func didTapScreen(recognizer: UITapGestureRecognizer) {
        if didInitializeScene {
            if let camera = sceneView.session.currentFrame?.camera {
                var translation = matrix_identity_float4x4
                translation.columns.3.z = -1.0
                let transform = camera.transform * translation
                let position = SCNVector3(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
                sceneController.addSphere(position: position)
            }
        }
    }

    // MARK: - ARSCNViewDelegate
    
    func drawScene() {
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: “art.scnassets/Productivity Pod.scn”)!
        
        // Set the scene to the view
        sceneView.scene = scene
        
        let light = SCNLight()
        light.type = .omni
        light.intensity = 2000.0
        light.color = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.8)
        
        
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(0, 1, 0)
        scene.rootNode.addChildNode(lightNode)
        
        let url = Bundle.main.url(forResource: "Podlife v7 bottom", withExtension: "stl")!
        let node = try! BinarySTLParser.createNodeFromSTL(at: url, unit: .millimeter)
        scene.rootNode.addChildNode(node)
    }
}
