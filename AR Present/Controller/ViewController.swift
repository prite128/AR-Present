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

class ViewController: UIViewController, ARSCNViewDelegate  , KeyDataDelegate{
  
    
    
    @IBOutlet var sceneView: ARSCNView!
    
  
    
    var configuration = ARImageTrackingConfiguration()
    
    var pictureImage : UIImage?
    
    var mainKeyData : MainKeyData   =   MainKeyData()
    
    var pictureModels : [PictureModel]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainKeyData.delegate    =   self
        
        mainKeyData.loadKeys()
        
//        loadKeys()
        
        sceneView.delegate = self
        
        sceneView.showsStatistics = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
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
              
                print("before if anchor")
                
                
                if let safePictureModels =   pictureModels {
                    
                    print("in if anchor")
                    
                    print(safePictureModels.count)
                    
                    safePictureModels.forEach { (PictureModel) in
                        
                            print("in view controller \(imageAnchor.referenceImage.name ) : \(PictureModel.ArModelName)")
                        
                        if imageAnchor.referenceImage.name  ==  PictureModel.ArModelName {
                            

                                
//                                print("beffore set image")
                            plane.firstMaterial?.diffuse.contentsTransform = SCNMatrix4Translate(SCNMatrix4MakeScale(1, -1, 1), 0, 1, 0)
                                plane.firstMaterial?.diffuse.contents   =  PictureModel.ArPictureImage
                             
                            
//                            print("after set image \(PictureModel.ArPictureImage)")
                                
                            
                            
                        }
                    }
                    
                }
                
                
                planeNode.eulerAngles.x =   -.pi/2
                
                planeNode.eulerAngles.y =   -.pi/2
                
                node.addChildNode(planeNode)
                
                
                
            }
            
            
            return node
            
        }
    // MARK: - MainKeyModel delegate
    
    func didUpdateARReference(References: Set<ARReferenceImage>) {
        
            configuration.trackingImages = References
            sceneView.session.run(configuration)
            
            print("ARReferenceImages in delegate : \(References.count)")
          
      }
      
    func didUpdateImages(with PictureModel : [PictureModel]) {
        
        print("in view controller PictureModel : \(PictureModel.count) ")
        
//        let safeArray = Array(Set(PictureModel))
        
        PictureModel.forEach { (PictureModel) in
            print("didUpdateImages with ArPictureName : \(PictureModel.ArPictureName!)")
            print("didUpdateImages with ArModelName : \(PictureModel.ArModelName!)")
        }
            pictureModels   =   PictureModel
        
      }
    
}

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()

        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }

    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}


