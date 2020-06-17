//
//  ViewController.swift
//  AR Present
//
//  Created by prite on 29/5/2563 BE.
//  Copyright © 2563 prite. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Firebase

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    let dbForUser  =   Firestore.firestore()
    let dbForSystem  =   Firestore.firestore()
    
    let storage = Storage.storage()
    var storageRef: StorageReference    =   StorageReference ()
    
    var keysFromAccount:[String] =   []
    
    var ARReferenceImages : Set<ARReferenceImage>   = Set<ARReferenceImage>()
    
    var configuration = ARImageTrackingConfiguration()
    
    var pictureImage : UIImage?
    
    var mainKeys:[MainKey]  = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadKeys()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        //        // Create a new scene
        //        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        //
        //        // Set the scene to the view
        //        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
//        let configuration = ARWorldTrackingConfiguration()
        
        configuration.maximumNumberOfTrackedImages  =   2
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
            
            let node    =   SCNNode()
            
            if let imageAnchor  =   anchor as? ARImageAnchor {
                
                print("found")
                
//                let videoNode   =   SKVideoNode(fileNamed: "trak.m4v")
//
//
//                videoNode.play()
//
//                let videoScene  =   SKScene(size: CGSize(width: 1920, height: 1080))
//
//                videoNode.position  =   CGPoint(x: videoScene.size.width/2, y: videoScene.size.height/2)
//
//                videoNode.yScale    =   -1.0
//
//                videoScene.addChild(videoNode)
                
                
//                let plane   =   SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
                
                let plane   =   SCNPlane(width: imageAnchor.referenceImage.physicalSize.height, height: imageAnchor.referenceImage.physicalSize.width)
                
                let planeNode = SCNNode(geometry: plane)
                
                if let image    =   pictureImage {
                    

                    plane.firstMaterial?.diffuse.contents   =  image
                    
                }
                
                planeNode.eulerAngles.x =   -.pi/2
                
                planeNode.eulerAngles.y =   -.pi/2
                
                node.addChildNode(planeNode)
                
                
                
            }
            
            
            return node
            
        }
}

// MARK: - load  Data

extension ViewController {
    
    func loadKeys(){
        
        if let account = Auth.auth().currentUser?.email {
            
            print("in load key function")
            
            dbForUser.collection("Account").document(account).collection("Keys").addSnapshotListener { (QuerySnapshot, Error) in
                
                if let error    =   Error {
                    print(error)
                }
                else if let snapshotDocument    =   QuerySnapshot?.documents {
                    
                    for doc in snapshotDocument {
                        
                        let data    =   doc.data()
                        if let key =    data["key"] as? String {
                            self.keysFromAccount.append(key)
                        }
                    }
                }
            }
            loadMainKeys()
        }
    }
    
    
    func loadMainKeys(){
        
        dbForSystem.collection("Key").addSnapshotListener { (QuerySnapshot, Error) in
            
            print("in loadMainKeys")
            if let error    =   Error {
                
                print(error)
                
            }
            else if let snapshotDocument    =   QuerySnapshot?.documents {
                
                for doc in snapshotDocument {
                    
                    let data    =   doc.data()
                    let idData  =   "\(doc.documentID)"
                    
                    
                    if self.keysFromAccount.contains(idData) , let pathModel =    data["Path-Molde"] as? String , let  pathPicture =    data["Path-Picture"] as? String
                    {
                        
                        let tempMainKey =   MainKey(pathModel: pathModel, pathPicture: pathPicture)
                        
                        print("\(pathModel) : \(pathPicture)")
                        
                        self.mainKeys.append(tempMainKey)
                        
                        self.addImageToReference()
                        
                    }
                }
            }
        }
        
//        addImageToReference()
    }
    
    
    func addImageToReference(){
        
        mainKeys.forEach { (key) in
            
            let tempImageReference   =   storageRef.child(key.pathModel)
            print("befoore 192")
            let tempImagePicture  =   storageRef.child(key.pathPicture)
            
            
            tempImageReference.getData(maxSize: 15 * 1024 * 1024) { data, error in
                
                if let error = error {
                    print(error)
                } else {
                    print("befoore if 201")
                    if  let image = UIImage(data: data!) {
                        
                      let arImage = ARReferenceImage(image.cgImage!, orientation: CGImagePropertyOrientation.up, physicalWidth: 0.09)
                        arImage.name = tempImageReference.name
                        self.ARReferenceImages.insert(arImage)
                        
                        self.configuration.trackingImages = self.ARReferenceImages
                        self.sceneView.session.run(self.configuration)
                        
                        print("ARReferenceImages1 : \(self.ARReferenceImages.count)")
                    }
                }
            }
            
            tempImagePicture.getData(maxSize: 15 * 1024 * 1024) { data, error in

                if let error = error {
                    print(error)
                } else {
                    if  let image = UIImage(data: data!) {

                        self.pictureImage  =   image
                        
                        print("add image suceesful")

                    }
                }
            }
            
            
        }
        

        
    }
    
    
    
    
    
    
}
