import UIKit
import CoreData
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class ComposeViewController: UIViewController {
    
  var db: Firestore!
  var currentUser: User?
  var taskArray = [Task]()
  var dataFilePath: URL?
  let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

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
    taskToSave.uuid = currentUser?.uid ?? ""
    taskToSave.priority = 0
    taskToSave.createdOn = Date()
    taskToSave.updatedOn = Date()
    
    if (currentUser == nil) {
      taskArray.append(taskToSave)
      
      do {
        try context.save()
      } catch {
        print("Error saving context \(error)")
      }
    } else {
      var ref: DocumentReference? = nil
      let dataToSave = [
        "user_id": taskToSave.uuid!,
        "text": taskToSave.text!,
        "done": taskToSave.done,
        "priority": taskToSave.priority,
        "created_on": taskToSave.createdOn!,
        "updated_on": taskToSave.updatedOn!,
        ] as [String : Any]
      
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
