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
    func didUpdateImages(with PictureModel : [PictureModel])
}

struct MainKeyData {
    
    private let dbForUser  =   Firestore.firestore()
    private let dbForSystem  =   Firestore.firestore()
    
    private let storage = Storage.storage()
    
    
    
    private static var pictureModels    :   [PictureModel] =   []
    
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
            
//            print("in loadMainKeys")
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
        
        MainKeyData.pictureModels   =   []
        
        
        mainKeys.forEach { (key) in
            
            let tempImageReference   =   storageRef.child(key.pathModel)
            let tempImagePicture  =   storageRef.child(key.pathPicture)
            
            var tempPictureModel    =   PictureModel()
            
            tempImageReference.getData(maxSize: 15 * 1024 * 1024) { data, error in
                
                if let error = error {
                    print(error)
                } else {
                    
                    if  let image = UIImage(data: data!) {
                        
                        let arImage = ARReferenceImage(image.cgImage!, orientation: CGImagePropertyOrientation.up, physicalWidth: 0.09)
                        arImage.name = tempImageReference.name
                        ARReferenceImages.insert(arImage)
                        
                        self.delegate?.didUpdateARReference(References: ARReferenceImages)
                        tempPictureModel.ArModelImage   =   arImage
                        tempPictureModel.ArModelName    =   tempImageReference.name
//                        print("tempImageReference.name : \(tempImageReference.name)")
                        
                        self.getPictureImage(pictureModel: tempPictureModel, imagePictureRef: tempImagePicture)
                    }
                }
            }
            
            
            
        }
        
    }
    
    
     func getPictureImage(pictureModel  :  PictureModel , imagePictureRef: StorageReference ){
        
        var tempPictureModel    = pictureModel
        
//        print("in getPictureImage \(MainKeyData.pictureModels.count)")
        
        imagePictureRef.getData(maxSize: 15 * 1024 * 1024) { data, error in
            
            if let error = error {
                print(error)
            } else {
                if  let image = UIImage(data: data!) {
                    
                    
                    tempPictureModel.ArPictureImage   =   image
                    tempPictureModel.ArPictureName    =   imagePictureRef.name
                    
//                    print(tempPictureModel.ArPictureImage)
                    
                    print("before append pictureModels ")
                    
                    MainKeyData.self.pictureModels.append(tempPictureModel)
                    
                    
                    print("in getPictureImage before pass data :  \(MainKeyData.pictureModels.count)")
                    
                    self.delegate?.didUpdateImages(with: MainKeyData.self.pictureModels)
                    
                    print("add image suceesful")
                    
                }
            }
        }
        
    }
    
}
