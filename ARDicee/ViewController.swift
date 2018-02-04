//
//  ViewController.swift
//  ARDicee
//
//  Created by SREENATH T V on 01/02/18.
//  Copyright © 2018 SREENATH T V. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var diceArray = [SCNNode]()
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        // Set the view's delegate
        sceneView.delegate = self
        
        // Create a new scene
        sceneView.autoenablesDefaultLighting = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if ARWorldTrackingConfiguration.isSupported == true {
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        // Run the view's session
        sceneView.session.run(configuration)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    //MARK: Create Scene
    func createScene() {
        

    }
    //MARK:- Touch Delegate
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            if let hitResult = results.first {
                let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!

                if  let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
                    diceNode.position = SCNVector3(x: hitResult.worldTransform.columns.3.x, y: hitResult.worldTransform.columns.3.y + diceNode.boundingSphere.radius, z: hitResult.worldTransform.columns.3
                .z)
                    diceArray.append(diceNode)
                    guard sceneView.scene.rootNode.addChildNode(diceNode) != nil else {fatalError()}
                    
                    rollAll()
                    roll(dice: diceNode)
                }
            }
    
        }
    }
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        rollAll()
    }
    func rollAll() {
        if diceArray.isEmpty == false {
            for dice in diceArray {
                roll(dice:dice)
                
            }
        }
    }
    func roll(dice: SCNNode) {
        let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        dice.runAction(
            SCNAction.rotateBy(x: CGFloat(randomX*5),
                               y: 0,
                               z: CGFloat(randomZ*5),
                               duration: 0.5)
        )
    }
    @IBAction func deleteAll(_ sender: UIBarButtonItem) {
        if diceArray.isEmpty == false {
            for dice in diceArray {
                dice.removeFromParentNode()
            }
        }
    }
    @IBAction func rollAgain(_ sender: UIBarButtonItem) {
        rollAll()
    }
    //MARK: Scene Delegate
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
            let planeAnchor = anchor as! ARPlaneAnchor
            let scenePlane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            let planeNode = SCNNode()
            planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            let gridMaterial = SCNMaterial()
            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            scenePlane.materials = [gridMaterial]
            planeNode.geometry = scenePlane
            node.addChildNode(planeNode)
        }
    }
}
