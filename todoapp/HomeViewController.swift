import UIKit
import Firebase
import FirebaseFirestore

struct Tasks {
  var uuid: String
  var text: String
  var priority: Int
}

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

  @IBOutlet weak var tableView: UITableView!
    
  var db: Firestore!
  var databaseHandle:DatabaseHandle?
  var taskArray = [Tasks]()
  var taskListener: ListenerRegistration!
  var currentUser: User?
  var handle: AuthStateDidChangeListenerHandle?
  let defaults = UserDefaults.standard

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    handle = Auth.auth().addStateDidChangeListener { (auth, user) in
      if user != nil {
        self.currentUser = user
        self.taskListener = self.db.collection("tasks").whereField("user_id", isEqualTo: self.currentUser?.uid ?? "").addSnapshotListener { (querySnapshot, err) in
          guard let documents = querySnapshot?.documents else {
            print("Error fetching documents: \(err!)")
            return
          }
          self.taskArray.removeAll()
          for document in documents {
            if querySnapshot != nil {
              let text = document.data()["text"] as? String ?? ""
              let priority = document.data()["priority"] as? Int ?? 0
              let uuid = document.documentID
              let task = Tasks(uuid: uuid, text: text, priority: priority)
              self.taskArray.append(task)
            }
          }
          self.tableView.reloadData()
        }
      } else {
        self.currentUser = nil
        self.taskArray.removeAll()
        if let items = self.defaults.array(forKey: "taskArray") as? [Tasks] {
          self.taskArray = items
        }
        self.tableView.reloadData()
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
    let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell")
    cell?.textLabel?.text = taskArray[indexPath.row].text
    return cell!
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    performSegue(withIdentifier: "gotoEdit", sender: indexPath)
  }
    
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "gotoEdit" {
      let destinationVC = segue.destination as! EditViewController
      if let indexPath = sender as? NSIndexPath{
        let selectedTask = self.taskArray[indexPath.row] as Tasks
        destinationVC.selectedTask = selectedTask
      }
    }
  }
  
  //delete row and commit to database
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      self.taskArray.remove(at: indexPath.row)
      if currentUser != nil {
        db.collection("tasks").document(taskArray[indexPath.row].uuid).delete() { err in
          if let err = err {
            print("Error removing document: \(err)")
          } else {
            print("Document successfully removed!")
          }
        }
      } else {
        defaults.set(taskArray, forKey: "taskArray")
      }
      tableView.deleteRows(at: [indexPath], with: .automatic)
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
  
  @IBAction func unwindToHome(_ unwindSegue: UIStoryboardSegue) {
//    let sourceViewController = unwindSegue.source
    // Use data from the view controller which initiated the unwind segue
  }
  
  @IBAction func accountTapped(_ sender: Any) {
    if (currentUser != nil) {
      self.performSegue(withIdentifier: "loggedInSegue", sender: self)
    } else {
      self.performSegue(withIdentifier: "notLoggedInSegue", sender: self)
    }
  }
}
