import UIKit
import Firebase
import CoreData

class EditViewController: UIViewController, UITextViewDelegate {
    
  @IBOutlet weak var editTextView: UITextView!

  var appDelegate = UIApplication.shared.delegate as! AppDelegate
  let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
  var selectedTaskUuid = ""
  var db : Firestore!

  override func viewDidLoad() {
    super.viewDidLoad()
    self.editTextView.delegate = self
    print("in edit: ")
    print(selectedTaskUuid)
//    db = Firestore.firestore()
//    db.collection("tasks").whereField("uuid", isEqualTo: selectedTaskUuid).getDocuments { (querySnapshot, err) in
//      if let err = err {
//        print("Error getting documents: \(err)")
//      } else {
//        for documents in querySnapshot!.documents {
//          self.editTextView.text = documents.data()["text"] as? String ?? ""
//        }
//      }
//    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBAction func editPost(_ sender: Any) {
//    let docToUpdate = db.collection("tasks").document(selectedTaskUuid)
//    updateData(["text": editTextView.text ?? ""])
  }

  @IBAction func cancelPost(_ sender: Any) {
    presentingViewController?.dismiss(animated: true, completion: nil)
  }
}
