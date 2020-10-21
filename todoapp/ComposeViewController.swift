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
    presentingViewController?.dismiss(animated: true, completion: nil)
    
    guard let taskText = textView.text, !taskText.isEmpty else { return }
    
    let taskToSave = Task(context: self.context)
    taskToSave.text = taskText
    taskToSave.done = false
    taskToSave.userid = currentUser?.uid ?? ""
    taskToSave.uuid = UUID().uuidString
    taskToSave.priority = 0
    taskToSave.createdOn = Date()
    taskToSave.updatedOn = Date()
    
    if (currentUser == nil) {
      appDelegate.saveContext()
    } else {
      let dataToSave = [
        "uuid": taskToSave.uuid!,
        "userid": taskToSave.userid!,
        "text": taskToSave.text!,
        "done": taskToSave.done,
        "priority": taskToSave.priority,
        "created_on": taskToSave.createdOn!,
        "updated_on": taskToSave.updatedOn!,
        ] as [String : Any]
      
      db.collection("tasks").document(taskToSave.uuid!).setData(dataToSave) { (error) in
        if let error = error {
          print("Add task failed: \(error.localizedDescription)")
        } else {
          print("Task saved: \(taskToSave.uuid!)")
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
