//
//  SettingTableViewController.swift
//  AR Present
//
//  Created by prite on 8/6/2563 BE.
//  Copyright © 2563 prite. All rights reserved.
//

import UIKit
import Firebase

class SettingTableViewController: UITableViewController {
    
    let db  =   Firestore.firestore()
    
    var keys : [KeysModel] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("before function load key")
        
        loadKeys()
        
    }
    
    // MARK: - Table view data source
    
    //    override func numberOfSections(in tableView: UITableView) -> Int {
    //        // #warning Incomplete implementation, return the number of sections
    //        return keys?.count ?? 0
    //    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return keys.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "KeyCellReuse", for: indexPath)
        
        cell.textLabel?.text    =   keys[indexPath.row].Keys
        
        return cell
        
    }
    
    func loadKeys(){
        
        if let account = Auth.auth().currentUser?.email {
            
            print("in load key function")
            
            db.collection("Account").document(account).collection("Keys").addSnapshotListener { (QuerySnapshot, Error) in
                
                if let error    =   Error {
                    print(error)
                }
                else if let snapshotDocument    =   QuerySnapshot?.documents {
                    
                    for doc in snapshotDocument {
                        
                        let data    =   doc.data()
                        if let key =    data["key"] as? String {
                            
                            let tempKey =   KeysModel(Keys: key)
                            
                            self.keys.append(tempKey)
                            print("tempKey : \(self.keys.count)")
                            print("tempKey : \(tempKey.Keys)")
                            
                            DispatchQueue.main.async {
                                
                                self.tableView.reloadData()
                                
                              
                            }
                        }
                        
                    }
                    
                }
            }
            
            
        }
        
    }
    
}
