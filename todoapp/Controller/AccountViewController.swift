import UIKit
import Firebase
import GoogleSignIn

class AccountViewController: UIViewController {

  @IBOutlet weak var textLabel: UILabel!
  
  var currUser: User!
  override func viewDidLoad() {
    super.viewDidLoad()
    currUser = Auth.auth().currentUser
    textLabel.text = currUser.email
        // Do any additional setup after loading the view.
  }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

  @IBAction func signOut(_ sender: Any) {
    GIDSignIn.sharedInstance().signOut()
    let firebaseAuth = Auth.auth()
    do {
      try firebaseAuth.signOut()
    } catch let signOutError as NSError {
      print ("Error signing out: %@", signOutError)
    }
    self.performSegue(withIdentifier: "unwindFromAccount", sender: self)
  }
}
