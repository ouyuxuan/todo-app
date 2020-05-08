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
  
  func firebaseLogin(_ credential: AuthCredential) {
    if let user = Auth.auth().currentUser {
      user.link(with: credential) { (result, error) in
        if let error = error {
          self.showMessagePrompt(error.localizedDescription)
          return
        }
      }
    } else {
      Auth.auth().signIn(with: credential) { (result, error) in
        if let error = error {
          let authError = error as NSError
          if (authError.code == AuthErrorCode.secondFactorRequired.rawValue) {
            // The user is a multi-factor user. Second factor challenge is required.
            let resolver = authError.userInfo[AuthErrorUserInfoMultiFactorResolverKey] as! MultiFactorResolver
            var displayNameString = ""
            for tmpFactorInfo in (resolver.hints) {
              displayNameString += tmpFactorInfo.displayName ?? ""
              displayNameString += " "
            }
            self.showTextInputPrompt(withMessage: "Select factor to sign in\n\(displayNameString)", completionBlock: { userPressedOK, displayName in
              var selectedHint: PhoneMultiFactorInfo?
              for tmpFactorInfo in resolver.hints {
                if (displayName == tmpFactorInfo.displayName) {
                  selectedHint = tmpFactorInfo as? PhoneMultiFactorInfo
                }
              }
              PhoneAuthProvider.provider().verifyPhoneNumber(with: selectedHint!, uiDelegate: nil, multiFactorSession: resolver.session) { verificationID, error in
                if error != nil {
                  print("Multi factor start sign in failed. Error: \(error.debugDescription)")
                } else {
                  self.showTextInputPrompt(withMessage: "Verification code for \(selectedHint?.displayName ?? "")", completionBlock: { userPressedOK, verificationCode in
                    let credential: PhoneAuthCredential? = PhoneAuthProvider.provider().credential(withVerificationID: verificationID!, verificationCode: verificationCode!)
                    let assertion: MultiFactorAssertion? = PhoneMultiFactorGenerator.assertion(with: credential!)
                    resolver.resolveSignIn(with: assertion!) { result, error in
                      if error != nil {
                        print("Multi factor finanlize sign in failed. Error: \(error.debugDescription)")
                      } else {
                        self.navigationController?.popViewController(animated: true)
                      }
                    }
                  })
                }
              }
            })
          } else {
            self.showMessagePrompt(error.localizedDescription)
            return
          }
          self.showMessagePrompt(error.localizedDescription)
          return
        }
      }
    }
  }
  
  func addUserToFirestore(_ uid: String?, _ email: String?, _ firstName: String?, _ lastName: String?) {
    db.collection("users").addDocument(data: ["uid": uid!, "email": email!, "first_name": firstName!, "last_name": lastName!])
    self.performSegue(withIdentifier: "unwindFromSignIn", sender: self)
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
    
    Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
      if error != nil {
        self.errorLabel.text = error?.localizedDescription
        self.errorLabel.alpha = 1
      } else {
        self.performSegue(withIdentifier: "unwindFromSignIn", sender: self)
      }
    }
  }
}
