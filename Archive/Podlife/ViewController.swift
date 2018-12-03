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

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var didInitializeScene: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapScreen))
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set the view's delegate
        sceneView.delegate = self
//        sceneView.session.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        // Run the view's session
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        self.drawScene(position: nil)
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
                translation.columns.3.z = -3.0
                translation.columns.3.x = 3.0
                let transform = camera.transform * translation
                let position = SCNVector3(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
                self.drawScene(position: position)
            }
        }
    }

    func updatePositionAndOrientationOf(_ node: SCNNode, withPosition position: SCNVector3, relativeTo referenceNode: SCNNode) {
        let referenceNodeTransform = matrix_float4x4(referenceNode.transform)
        
        // Setup a translation matrix with the desired position
        var translationMatrix = matrix_identity_float4x4
        translationMatrix.columns.3.x = position.x
        translationMatrix.columns.3.y = position.y
        translationMatrix.columns.3.z = position.z
        
        // Combine the configured translation matrix with the referenceNode's transform to get the desired position AND orientation
        let updatedTransform = matrix_multiply(referenceNodeTransform, translationMatrix)
        node.transform = SCNMatrix4(updatedTransform)
    }
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if !didInitializeScene {
            if sceneView.session.currentFrame?.camera != nil {
                didInitializeScene = true
                self.drawScene(position: nil)
            }
        }
    }
    
    func drawScene(position: SCNVector3?) {
        // Create a new scene
//        let scene = SCNScene(named: "art.scnassets/Podlife v7 bottom.scn")!
        let scene = SCNScene()
//        scene.rootNode.scale = SCNVector3(0.1, 0.1, 0.1)
//        scene.rootNode.position = SCNVector3(x: 20, y: 0, z: -2)
        
        let boxGeometry = SCNBox(width: 10.0, height: 10.0, length: 10.0, chamferRadius: 1.0)
        let boxNode = SCNNode(geometry: boxGeometry)
        scene.rootNode.addChildNode(boxNode)
        
        sceneView.autoenablesDefaultLighting = true
        sceneView.allowsCameraControl = true
        // Set the scene to the view
        sceneView.scene = scene[]
        
//        updatePositionAndOrientationOf(scene.rootNode, withPosition: position, relativeTo: sceneView.pointOfView!)
//
//        let light = SCNLight()
//        light.type = .omni
//        light.intensity = 2000.0
//        light.color = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.8)
//
//
//        let lightNode = SCNNode()
//        lightNode.light = light
//        lightNode.position = SCNVector3(0, 1, 0)
//        scene.rootNode.addChildNode(lightNode)
        
//        let url = Bundle.main.url(forResource: "Podlife v7 bottom", withExtension: "stl")!
//        let node = try! BinarySTLParser.createNodeFromSTL(at: url, unit: .millimeter)
//        scene.rootNode.addChildNode(node)
    }
}
