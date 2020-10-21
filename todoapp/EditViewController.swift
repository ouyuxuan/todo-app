import UIKit
import Firebase
import CoreData

class EditViewController: UIViewController {
    
  @IBOutlet weak var editTextView: UITextView!

  var appDelegate = UIApplication.shared.delegate as! AppDelegate
  let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
  var selectedTaskUuid = ""
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let request = Task.fetchRequest() as NSFetchRequest<Task>
    let predicate = NSPredicate(format: "uuid == %@", selectedTaskUuid)
    request.predicate = predicate
    request.fetchLimit = 1

    do {
      let task = try context.fetch(request)
      editTextView.text = task.first?.text
    } catch {
      print("Error fetching context \(error)")
    }
    // Do any additional setup after loading the view.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBAction func editPost(_ sender: Any) {
    let task = Task(context: context)
    task.text = editTextView.text
    appDelegate.saveContext()
    presentingViewController?.dismiss(animated: true, completion: nil)
  }

  @IBAction func cancelPost(_ sender: Any) {
    presentingViewController?.dismiss(animated: true, completion: nil)
  }
}
