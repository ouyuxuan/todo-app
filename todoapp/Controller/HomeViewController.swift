import UIKit
import CoreData
import Firebase
import FirebaseFirestore

struct TaskStruct {
  var createdOn: Date?
  var done: Bool
  var priority: Int
  var text: String
  var updatedOn: Date?
  var uuid: String
  var userid: String
}

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

  @IBOutlet weak var tableView: UITableView!
  
  var db: Firestore!
  var taskListener: ListenerRegistration!
  var currentUser: User?
  var handle: AuthStateDidChangeListenerHandle?
  var appDelegate = UIApplication.shared.delegate as! AppDelegate
  let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
  var taskArray: [TaskStruct] = []
  let deviceId = UIDevice.current.identifierForVendor?.uuidString
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    handle = Auth.auth().addStateDidChangeListener { (auth, user) in
      self.currentUser = user
      self.taskArray.removeAll()
      self.taskListener = self.db.collection("tasks").whereField("userid", isEqualTo: self.currentUser?.uid ?? self.deviceId!).addSnapshotListener { (querySnapshot, err) in
        if let err = err {
          print("Error getting documents: \(err)")
          let alert = UIAlertController(title: "Error", message: "Could not fetch list items", preferredStyle: UIAlertController.Style.alert)
          alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
          self.present(alert, animated: true, completion: nil)
        } else {
          for document in querySnapshot!.documents {
            let task = TaskStruct(
              done: document.data()["done"] as? Bool ?? false,
              priority: Int(document.data()["priority"] as? Int ?? 0),
              text: document.data()["text"] as? String ?? "",
              uuid: document.data()["uuid"] as? String ?? "",
              userid: document.data()["userid"] as? String ?? "")
            self.taskArray.append(task)
          }
          self.tableView.reloadData()
        }
      }
    self.setTitleDisplay(user)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    db = Firestore.firestore()
    tableView.delegate = self
    tableView.dataSource = self
  }
  
  
  func setTitleDisplay(_ user: User?) {
    if let email = user?.email {
      self.navigationItem.title = "Welcome \(email)"
    } else {
      self.navigationItem.title = "To-Do List"
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
    
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return taskArray.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let task = taskArray[indexPath.row]
    let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell")
    cell?.textLabel?.text = task.text
    return cell!
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "goToEdit" {
      let destinationVC = segue.destination as! EditViewController
      if let indexPath = sender as? NSIndexPath{
        let selectedTask = self.taskArray[indexPath.row]
        destinationVC.selectedTaskUuid = selectedTask.text
      }
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    performSegue(withIdentifier: "goToEdit", sender: indexPath)
  }
  
  //delete row and commit to database
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      
      db.collection("tasks").document(taskArray[indexPath.row].uuid).delete() { err in
        if let err = err {
          print("Error removing document: \(err)")
          let alert = UIAlertController(title: "Error", message: "Could not delete list item", preferredStyle: UIAlertController.Style.alert)
          alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
          self.present(alert, animated: true, completion: nil)
        } else {
          print("Document successfully removed!")
        }
      }
      taskArray.remove(at: indexPath.row)
      tableView.reloadData()
    }
  }
    
  //can edit row
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    Auth.auth().removeStateDidChangeListener(handle!)
    taskListener?.remove()
  }
  
  @IBAction func unwindToHome(_ unwindSegue: UIStoryboardSegue) {}
  
  @IBAction func accountTapped(_ sender: Any) {
    if (currentUser != nil) {
      self.performSegue(withIdentifier: "loggedInSegue", sender: self)
    } else {
      self.performSegue(withIdentifier: "notLoggedInSegue", sender: self)
    }
  }
}
