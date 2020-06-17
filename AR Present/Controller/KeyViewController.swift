//
//  KeyViewController.swift
//  AR Present
//
//  Created by prite on 5/6/2563 BE.
//  Copyright © 2563 prite. All rights reserved.
//

import UIKit
import Firebase

class KeyViewController: UIViewController {
    
    @IBOutlet weak var keyTextField: UITextField!
    
    let db  =   Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        
        if let account = Auth.auth().currentUser?.email , let key   =   keyTextField.text {
            
            let docData : [String : Any ]   =   [
                
                "key"  :  key
                
            ]
            
            //            db.collection("Account").document(account).setData(docData , merge: false ) { (Error) in
            //
            //                if let error    =   Error {
            //                    print(error)
            //                }
            //                else{
            //                    print("Add data success")
            //                }
            //            }
            
            db.collection("Account").document(account).collection("Keys").addDocument(data: docData) { (error) in
                
                if let error    =   error {
                    print(error)
                }
                else{
                    print("Add data success")
                }
            }
        }
        
    }
    
    
    
}
