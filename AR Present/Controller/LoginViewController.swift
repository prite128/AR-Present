//
//  LoginViewController.swift
//  AR Present
//
//  Created by prite on 4/6/2563 BE.
//  Copyright © 2563 prite. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    
    @IBOutlet weak var userNameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        
        if let email   =   userNameTextField.text , let password = passwordTextField.text {
            
            Auth.auth().signIn(withEmail: email, password: password) {  authResult, error in
               
                if let e = error {
                    print(e)
                    
                }
                else{
                    self.performSegue(withIdentifier: K.loginToArSegue, sender: self)
                }
                 
            }
        }
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
