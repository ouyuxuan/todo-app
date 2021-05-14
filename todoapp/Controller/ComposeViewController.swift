import UIKit
import CoreData
import Firebase
import FirebaseFirestore

class ComposeViewController: UIViewController {
    
  private var appDelegate = UIApplication.shared.delegate as! AppDelegate
  private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
  var db: Firestore!
  var currentUser: User?
  let deviceId = UIDevice.current.identifierForVendor?.uuidString
  
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
    let dataToSave = [
      "uuid": uuid,
      "userid": currentUser?.uid ?? deviceId!,
      "text": taskText,
      "done": false,
      "priority": 0,
      "created_on": Date(),
      "updated_on": Date(),
      ] as [String : Any]
    
    db.collection("tasks").document(uuid).setData(dataToSave) { (error) in
      if let error = error {
        print("Add task failed: \(error.localizedDescription)")
        let alert = UIAlertController(title: "Error", message: "Failed to save item", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
      } else {
        print("Task saved: \(uuid)")
      }
    }
    
    presentingViewController?.dismiss(animated: true, completion: nil)
  }

  @IBAction func cancelTapped(_ sender: Any) {
    presentingViewController?.dismiss(animated: true, completion: nil)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "fromComposeToHome" {
//      let destinationVC = segue.destination as! HomeViewController
    }
  }
}
