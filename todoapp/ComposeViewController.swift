import UIKit
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class ComposeViewController: UIViewController {
    
  var db: Firestore!
  var currentUser: User?
  let defaults = UserDefaults.standard

  @IBOutlet weak var textView: UITextView!

  override func viewDidLoad() {
    super.viewDidLoad()
    db = Firestore.firestore()
    currentUser = Auth.auth().currentUser
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBAction func saveTapped(_ sender: Any) {
    presentingViewController?.dismiss(animated: true, completion: nil)
    
    guard let taskText = textView.text, !taskText.isEmpty else { return }
    let dataToSave: [String: Any] = ["text": taskText, "priority": 0, "user_id": currentUser?.uid ?? "", "created_on": Timestamp(date: Date()), "updated_on": Timestamp(date: Date())]
    if (currentUser == nil) {
      var taskArray = defaults.array(forKey: "taskArray")
      taskArray?.append(dataToSave)
      defaults.set(taskArray, forKey: "taskArray")
    } else {
      var ref: DocumentReference? = nil
      
      ref = db.collection("tasks").addDocument(data: dataToSave) { (error) in
        if let error = error {
          print("Add task failed: \(error.localizedDescription)")
        } else {
          print("Task saved: \(ref!.documentID)")
        }
      }
    }
  }

  @IBAction func cancelTapped(_ sender: Any) {
    presentingViewController?.dismiss(animated: true, completion: nil)
  }

/*
// MARK: - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
}
*/

}
