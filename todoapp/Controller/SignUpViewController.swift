//
//  signUpViewController.swift
//  todoapp
//
//  Created by Ou Yu Xuan on 2020-05-07.
//  Copyright © 2020 Ou Yu Xuan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import SVProgressHUD

class SignUpViewController: UIViewController {
    
  @IBOutlet weak var emailTextField: UITextField!

  @IBOutlet weak var passwordTextField: UITextField!

  @IBOutlet weak var signUpButton: UIButton!

  @IBOutlet weak var signUpErrorLabel: UILabel!

  override func viewDidLoad() {
    super.viewDidLoad()
    signUpErrorLabel.alpha = 0
    // Do any additional setup after loading the view.
  }

  func validateFields() -> String? {
    if emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
      return "Please fill in all fields."
    }
    return nil
  }
    
  func showError(_ message: String) {
    signUpErrorLabel.text = message
    signUpErrorLabel.alpha = 1
  }
    
  @IBAction func signUpTapped(_ sender: Any) {
    let error = validateFields()
    let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
    let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
    if error != nil {
      showError(error!)
    } else {
      SVProgressHUD.show(withStatus: "Creating account")
      Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
        if error != nil {
          SVProgressHUD.dismiss()
          self.showError("Error in creating user: \(error!.localizedDescription)")
        } else {
          let db = Firestore.firestore()
          db.collection("users").addDocument(data: ["email": email, "id": result!.user.uid]) {    (error) in
            if error != nil {
              self.showError("User data could not be saved.")
            }
          }
          SVProgressHUD.dismiss()
          self.performSegue(withIdentifier: "unwindToHome", sender: nil)
        }
      }
    }
  }
}
