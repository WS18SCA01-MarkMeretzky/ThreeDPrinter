//
//  ViewController.swift
//  ThreeDPrinter
//
//  Created by Mark Meretzky on 1/17/19.
//  Copyright © 2019 New York University School of Professional Studies. All rights reserved.
//

import UIKit;
import SceneKit;
import ARKit;

typealias NodeTuple = (
    SCNGeometry.Type?,        //0 what subclass of SCNGeometry
    String,                   //1 name
    Any?,                     //2 geometry.firstMaterial.diffuse.contents
    Bool,                     //3 geometry.firstMaterial.isDoubleSided
    (Double, Double, Double), //4 position
    (Double, Double, Double), //5 eulerAngles in degrees
    (Double, Double, Double), //6 scale
    Any,                      //7 CGFloat arguments of init()
    [Any]                     //8 array of child nodes
);

//SceneKit-Primitives project from App Development with Swift, pp. 456-470.
//Main Building and Trunk are children of Campus.
//Sidewalks and Lawn are children of Main Building.
//Crown is the child of Trunk.

let campus: NodeTuple =
    (nil, "Campus", nil, false, (0.0, 0.2, 0.0), (0.0, 0.0, 0.0), (1.0, 1.0, 1.0), (), [
        (SCNBox.self, "Main Building", UIColor.brown, false, (0.0, 0.0, 0.0), (0.0, 0.0, 0.0), (1.0, 1.0, 1.0), (3.0, 1.0, 1.0, 0.0), [
            (SCNPlane.self, "Sidewalks", UIColor.gray, true, (0.0, -0.5, 0.0), (-90.0, 0.0, 0.0), (1.0, 1.0, 1.0), (3.5, 1.5), []),
            (SCNPlane.self, "Lawn", UIColor.green, true, (0.0, -0.501, 0.0), (-90.0, 0.0, 0.0), (1.0, 1.0, 1.0), (4.5, 2.0), [])
        ]),
        (SCNCylinder.self, "Trunk", UIColor.brown, false, (2.0, -0.25, 0.75), (0.0, 0.0, 0.0), (1.0, 1.0, 1.0), (0.05, 0.5), [
            (SCNSphere.self, "Crown", UIColor.green, false, (0.0, 0.25, 0.0), (0.0, 0.0, 0.0), (1.0, 1.0, 1.0), (0.2), [])
        ])
    ]);

//The Starship Enterprise.  Positive x is starboard, negative x is port.
//The rear of the ship is at the origin, the front is on the negative Z axis.

let enterprise: NodeTuple =
    (nil, "Enterprise", nil, false, (0.0, 0.0, 0.0), (0.0, 0.0, 0.0), (0.001, 0.001, 0.001), (), [
        (SCNCapsule.self, "Starboard Propulsion Unit", UIColor.gray, false, ( 157.0, 157.0, -257.0), (90.0, 0.0, 0.0), (1.0, 1.0, 1.0), (28.5, 504.0), []),
        (SCNCapsule.self, "Port Propulsion Unit",      UIColor.gray, false, (-157.0, 157.0, -257.0), (90.0, 0.0, 0.0), (1.0, 1.0, 1.0), (28.5, 504.0), []),
        
        (SCNBox.self, "Starboard Strut", UIColor.gray, false, ( 76.0, 76.0, -370.0), (0.0, 0.0, -45.0), (1.0, 1.0, 1.0), (15.0, 222.0, 30.0, 0.0), []),
        (SCNBox.self, "Port Strut",      UIColor.gray, false, (-76.0, 76.0, -370.0), (0.0, 0.0,  45.0), (1.0, 1.0, 1.0), (15.0, 222.0, 30.0, 0.0), []),
        
        (SCNCylinder.self, "Secondary Hull", UIColor.gray, false, (0.0, 0.0, -443.0), (-90.0, 0.0, 0.0), (1.0, 1.0, 1.0), (47.0, 340.0), []),
        (SCNCylinder.self, "Primary Hull", UIColor.gray, false, (0.0, 118.0, -739.0), (0.0, 0.0, 0.0), (1.0, 1.0, 1.0), (208.5, 50.0), []),
        (SCNBox.self, "Connector", UIColor.gray, false, (0.0, 74.0, -615.0), (-45.0, 0.0, 0.0), (1.0, 1.0, 1.0), (15.0, 120.0, 77.0, 0.0), [])
    ]);

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        // Set the view's delegate
        sceneView.delegate = self;
        
        // Show statistics such as fps and timing information.
        sceneView.showsStatistics = true;
        
        // Show the rx, y, z axes (red, green, blue).
        sceneView.debugOptions = [.showWorldOrigin];
        
        // Create a new scene (was originally "art.scnassets/ship.scn")
        guard let scene: SCNScene = SCNScene(named: "art.scnassets/empty.scn") else {
            fatalError("could not open art.scnassets/empty.scn");
        }
        
        let node: SCNNode = build(campus);   //or build(enterprise)
        scene.rootNode.addChildNode(node);
        
        // Set the scene to the view.
        sceneView.scene = scene;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration: ARWorldTrackingConfiguration = ARWorldTrackingConfiguration();

        // Run the view's session
        sceneView.session.run(configuration);
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause();
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node: SCNNode = SCNNode();
     
        return node;
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
    }
}

//These two functions are not methods of any class.

//Take a tuple decribing a tree of nodes, build the tree, and return the root node of the tree.

private func build(_ nodeTuple: NodeTuple) -> SCNNode {
    let node: SCNNode = SCNNode();
    node.name = nodeTuple.1;
    node.position = SCNVector3(nodeTuple.4.0, nodeTuple.4.1, nodeTuple.4.2);
    node.eulerAngles = SCNVector3(radians(nodeTuple.5.0), radians(nodeTuple.5.1), radians(nodeTuple.5.2));
    node.scale = SCNVector3(nodeTuple.6.0, nodeTuple.6.1, nodeTuple.6.2);
    
    if let typeOfGeometry = nodeTuple.0 {
        let geometry: SCNGeometry;

        if typeOfGeometry == SCNBox.self {
            let args: (Double, Double, Double, Double) = nodeTuple.7 as! (Double, Double, Double, Double);
            geometry = SCNBox(width: CGFloat(args.0), height: CGFloat(args.1), length: CGFloat(args.2), chamferRadius: CGFloat(args.3));
        } else if typeOfGeometry == SCNPyramid.self {
            let args: (Double, Double, Double) = nodeTuple.7 as! (Double, Double, Double);
            geometry = SCNPyramid(width: CGFloat(args.0), height: CGFloat(args.1), length: CGFloat(args.2));
        } else if typeOfGeometry == SCNPlane.self {
            let args: (Double, Double) = nodeTuple.7 as! (Double, Double);
            geometry = SCNPlane(width: CGFloat(args.0), height: CGFloat(args.1));
        } else if typeOfGeometry == SCNCylinder.self {
            let args: (Double, Double) = nodeTuple.7 as! (Double, Double);
            geometry = SCNCylinder(radius: CGFloat(args.0), height: CGFloat(args.1));
        } else if typeOfGeometry == SCNCone.self {
            let args: (Double, Double, Double) = nodeTuple.7 as! (Double, Double, Double);
            geometry = SCNCone(topRadius: CGFloat(args.0), bottomRadius: CGFloat(args.1), height: CGFloat(args.2));
        } else if typeOfGeometry == SCNSphere.self {
            let args: (Double) = nodeTuple.7 as! (Double);
            geometry = SCNSphere(radius: CGFloat(args));
        } else if typeOfGeometry == SCNCapsule.self {
            let args: (Double, Double) = nodeTuple.7 as! (Double, Double);
            geometry = SCNCapsule(capRadius: CGFloat(args.0), height: CGFloat(args.1));
        } else {
            fatalError("unimplemented subclass of SCNGeometry");
        }

        print("type(of: geometry) = \(type(of: geometry))");
        
        guard let firstMaterial: SCNMaterial = geometry.firstMaterial else {
            fatalError("geometry.firstMaterial == nil");
        }
        
        if let contents = nodeTuple.2 {
            firstMaterial.diffuse.contents = contents;
        }
        firstMaterial.isDoubleSided = nodeTuple.3;
        
        node.geometry = geometry;
    }
    
    for child in nodeTuple.8 {
        if let child: NodeTuple = child as? NodeTuple {
            node.addChildNode(build(child));
        } else {
            fatalError("could not downcast child \(child) to NodeTuple");
        }
    }
    
    return node;
}

//Convert degrees to radians.

private func radians(_ degrees: Double) -> Float {
    var measurement: Measurement = Measurement(value: degrees, unit: UnitAngle.degrees);
    measurement.convert(to: .radians);
    return Float(measurement.value);
}
