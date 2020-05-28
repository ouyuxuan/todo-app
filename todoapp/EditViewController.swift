import UIKit
import Firebase

class EditViewController: UIViewController {
    
  @IBOutlet weak var editTextView: UITextView!

  var selectedTask : Task?
  var dataFilePath: URL?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    editTextView.text = selectedTask?.text
    // Do any additional setup after loading the view.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBAction func editPost(_ sender: Any) {
    presentingViewController?.dismiss(animated: true, completion: nil)
//        let key:String = (ref?.child("Posts").childByAutoId().key)!
//        let post = editView.text
//        let childUpdates = ["/Posts/\(key))": post]
//        ref?.updateChildValues(childUpdates)
    //        ref?.child("Posts").childByAutoId().setValue(textView.text)
  }

  @IBAction func cancelPost(_ sender: Any) {
    presentingViewController?.dismiss(animated: true, completion: nil)
  }
}
