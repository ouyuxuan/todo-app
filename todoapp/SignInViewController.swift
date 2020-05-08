//
//  signInViewController.swift
//  todoapp
//
//  Created by Ou Yu Xuan on 2020-05-07.
//  Copyright © 2020 Ou Yu Xuan. All rights reserved.
//

import UIKit
import Firebase

class SignInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signInButton: UIButton!
    
    @IBOutlet weak var signInErrorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signInErrorLabel.alpha = 0
        // Do any additional setup after loading the view.
    }
    

    @IBAction func signInTapped(_ sender: Any) {
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error != nil {
                self.signInErrorLabel.text = error?.localizedDescription
                self.signInErrorLabel.alpha = 1
            } else {
                let homeViewController = self.storyboard?.instantiateViewController(identifier: "HomeVC") as? HomeViewController
                
                self.view.window?.rootViewController = homeViewController
                self.view.window?.makeKeyAndVisible()
            }
        }
    }
}
