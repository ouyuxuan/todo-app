import UIKit
import CoreData
import Firebase
import FirebaseFirestore

class ComposeViewController: UIViewController {
    
  private var appDelegate = UIApplication.shared.delegate as! AppDelegate
  private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
  var db: Firestore!
  var currentUser: User?

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
    guard let taskText = textView.text, !taskText.isEmpty else { return }
        
    let uuid = UUID().uuidString
    
    if (currentUser == nil) {
      let taskToSave = Task(context: self.context)
      taskToSave.text = taskText
      taskToSave.done = false
      taskToSave.userid = ""
      taskToSave.uuid = uuid
      taskToSave.priority = 0
      taskToSave.createdOn = Date()
      taskToSave.updatedOn = Date()
      appDelegate.saveContext()
      self.performSegue(withIdentifier: "fromComposeToHome", sender: self)
    } else {
      let dataToSave = [
        "uuid": uuid,
        "userid": currentUser?.uid ?? "",
        "text": taskText,
        "done": false,
        "priority": 0,
        "created_on": Date(),
        "updated_on": Date(),
        ] as [String : Any]
      
      db.collection("tasks").document(uuid).setData(dataToSave) { (error) in
        if let error = error {
          print("Add task failed: \(error.localizedDescription)")
        } else {
          print("Task saved: \(uuid)")
        }
      }
    }
    presentingViewController?.dismiss(animated: true, completion: nil)
  }

  @IBAction func cancelTapped(_ sender: Any) {
    presentingViewController?.dismiss(animated: true, completion: nil)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "fromComposeToHome" {
      let destinationVC = segue.destination as! HomeViewController
      destinationVC.loadTasks()
    }
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
