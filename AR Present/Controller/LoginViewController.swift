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
        
        userNameTextField.delegate  =   self
        passwordTextField.delegate  =   self
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
    
    
}

extension LoginViewController : UITextFieldDelegate {
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    
}
