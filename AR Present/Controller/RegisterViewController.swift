//
//  RegisterViewController.swift
//  AR Present
//
//  Created by prite on 4/6/2563 BE.
//  Copyright © 2563 prite. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {
    
    
    @IBOutlet weak var userNameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userNameTextField.delegate  =   self
        passwordTextField.delegate  =   self
        
    }
    
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        
        if let email   =   userNameTextField.text , let password    =   passwordTextField.text {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                
                if let e =  error {
                    print(e.localizedDescription)
                }
                else {
                    self.performSegue(withIdentifier: K.registerToArSegue, sender: self)
                }
            }
        }
        
        
    }
    
    
    
}
extension RegisterViewController : UITextFieldDelegate {
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    
}
