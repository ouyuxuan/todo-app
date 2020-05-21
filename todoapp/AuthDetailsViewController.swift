//
//  AccountDetailsViewController.swift
//  todoapp
//
//  Created by Ou Yu Xuan on 2020-05-08.
//  Copyright © 2020 Ou Yu Xuan. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FirebaseFirestore
import SVProgressHUD

class AuthViewController: UIViewController {

  @IBOutlet weak var emailTextField: UITextField!

  @IBOutlet weak var passwordTextField: UITextField!

  @IBOutlet weak var signInButton: UIButton!

  @IBOutlet weak var signUpButton: UIButton!

  @IBOutlet weak var errorLabel: UILabel!
  
  var db:Firestore!

  override func viewDidLoad() {
    super.viewDidLoad()
    db = Firestore.firestore()
    errorLabel.alpha = 0
  
    GIDSignIn.sharedInstance()?.presentingViewController = self
  
    // Automatically sign in the user.
    GIDSignIn.sharedInstance()?.restorePreviousSignIn()

    // Do any additional setup after loading the view.
  }
  
  func firebaseLogin(_ credential: AuthCredential, _ uid: String?, _ email: String?, _ firstName: String?, _ lastName: String?) {
    
    Auth.auth().signIn(with: credential) { (result, error) in
      if (error != nil) {
        print(error?.localizedDescription)
      } else {
        self.performSegue(withIdentifier: "unwindFromAuth", sender: self)
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
  
  @IBAction func signInTapped(_ sender: Any) {
    let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
    let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
    
    SVProgressHUD.show(withStatus: "Signing you in...")
    Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
      if error != nil {
        self.errorLabel.text = error?.localizedDescription
        self.errorLabel.alpha = 1
      } else {
        SVProgressHUD.dismiss()
        self.performSegue(withIdentifier: "unwindFromAuth", sender: self)
      }
    }
  }
}
