//
//  MainKeyData.swift
//  AR Present
//
//  Created by prite on 17/6/2563 BE.
//  Copyright © 2563 prite. All rights reserved.
//

import UIKit
import Firebase
import SceneKit
import ARKit

protocol KeyDataDelegate {
    
    func didUpdateARReference(References : Set<ARReferenceImage>)
    func didUpdateImages(Images : UIImage)
}

struct MainKeyData {
    
    private let dbForUser  =   Firestore.firestore()
    private let dbForSystem  =   Firestore.firestore()
    
    private let storage = Storage.storage()
    

    
    private  var pictureImage    : UIImage    =   UIImage()
    
     var delegate : KeyDataDelegate?
    
    
    
    
    
     func loadKeys(){
            
            if let account = Auth.auth().currentUser?.email {
                
                var keysFromAccount:[String] =   []
                
                print("in load key function")
                
                dbForUser.collection("Account").document(account).collection("Keys").addSnapshotListener { (QuerySnapshot, Error) in
                    
                    if let error    =   Error {
                        print(error)
                    }
                    else if let snapshotDocument    =   QuerySnapshot?.documents {
                        
                        for doc in snapshotDocument {
                            
                            let data    =   doc.data()
                            if let key =    data["key"] as? String {
                                keysFromAccount.append(key)
                                print(key)
                            }
                        }
                        
                        print("before call loadMainKeys : \(keysFromAccount.count)")
                        self.loadMainKeys(with : keysFromAccount)
                        
                    }
                }
                
            }
        }
        
        
     func loadMainKeys(with keysFromAccount : [String]){
            
        var mainKeys:[MainKey]  = []
        
            dbForSystem.collection("Key").addSnapshotListener { (QuerySnapshot, Error) in
                
                print("in loadMainKeys")
                if let error    =   Error {
                    
                    print(error)
                    
                }
                else if let snapshotDocument    =   QuerySnapshot?.documents {
                    
                    for doc in snapshotDocument {
                        
                        let data    =   doc.data()
                        let idData  =   "\(doc.documentID)"
                        
                        
                        if keysFromAccount.contains(idData) , let pathModel =    data["Path-Molde"] as? String , let  pathPicture =    data["Path-Picture"] as? String
                        {
                            
                            let tempMainKey =   MainKey(pathModel: pathModel, pathPicture: pathPicture)
                            
                            print("\(pathModel) : \(pathPicture)")
                            
                            mainKeys.append(tempMainKey)
                            
                            self.addImageToReference(with : mainKeys)
                            
                        }
                    }
                }
            }
            
        }
        
        
     func addImageToReference( with mainKeys:[MainKey] ){
            
        let storageRef: StorageReference    =   StorageReference ()
        
        var ARReferenceImages : Set<ARReferenceImage>   = Set<ARReferenceImage>()
        
        var pictureModels    :   [PictureModel] =   []
        
            mainKeys.forEach { (key) in
                
                let tempImageReference   =   storageRef.child(key.pathModel)
                let tempImagePicture  =   storageRef.child(key.pathPicture)
                
                var tempPictureModel    =   PictureModel()
                
                tempImageReference.getData(maxSize: 15 * 1024 * 1024) { data, error in
                    
                    if let error = error {
                        print(error)
                    } else {
                        print("befoore if 201")
                        if  let image = UIImage(data: data!) {
                            
                          let arImage = ARReferenceImage(image.cgImage!, orientation: CGImagePropertyOrientation.up, physicalWidth: 0.09)
                            arImage.name = tempImageReference.name
                            ARReferenceImages.insert(arImage)
                            
                            self.delegate?.didUpdateARReference(References: ARReferenceImages)
                            
                            tempPictureModel.ArModelImage   =   arImage
                            tempPictureModel.ArModelName    =   tempImageReference.name
                            
                            print("ARReferenceImages1 : \(ARReferenceImages.count)")
                            
                            
                        }
                    }
                }
                
                tempImagePicture.getData(maxSize: 15 * 1024 * 1024) { data, error in

                    if let error = error {
                        print(error)
                    } else {
                        if  let image = UIImage(data: data!) {

                            
                            tempPictureModel.ArPictureImage   =   image
                            tempPictureModel.ArPictureName    =   tempImagePicture.name
                            
                            print("before append pictureModels ")
                            
                            pictureModels.append(tempPictureModel)
                            
                            self.delegate?.didUpdateImages(Images: image)
                            
                            
                            print("add image suceesful")

                        }
                    }
                }
                
                
            }
            

            
        }
    
}
