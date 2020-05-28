import UIKit
import CoreData
import Firebase
import FirebaseFirestore

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

  @IBOutlet weak var tableView: UITableView!
    
  var db: Firestore!
  var databaseHandle:DatabaseHandle?
  var taskArray = [Task]()
  var taskListener: ListenerRegistration!
  var currentUser: User?
  var handle: AuthStateDidChangeListenerHandle?
  let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Task.plist")
  let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

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
              let task = Task()
              task.text = document.data()["text"] as? String ?? ""
              task.priority = Int32(document.data()["priority"] as? Int ?? 0)
              task.uuid = document.documentID
              self.taskArray.append(task)
            }
          }
          self.tableView.reloadData()
        }
      } else {
        self.currentUser = nil
        self.taskArray.removeAll()
        self.loadTasks()
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
  
  func loadTasks() {
    let request: NSFetchRequest<Task> = Task.fetchRequest()
    do {
      taskArray = try context.fetch(request)
      tableView.reloadData()
    } catch {
      print("Error fetching context \(error)")
    }
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
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "gotoEdit" {
      let destinationVC = segue.destination as! EditViewController
      destinationVC.dataFilePath = dataFilePath
      if let indexPath = sender as? NSIndexPath{
        let selectedTask = self.taskArray[indexPath.row] as Task
        destinationVC.selectedTask = selectedTask
      }
    }
    if segue.identifier == "goToCompose" {
      let destinationVC = segue.destination as! ComposeViewController
      destinationVC.dataFilePath = dataFilePath
      destinationVC.taskArray = taskArray
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    performSegue(withIdentifier: "gotoEdit", sender: indexPath)
  }
  
  //delete row and commit to database
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      if currentUser != nil {
        db.collection("tasks").document(taskArray[indexPath.row].uuid!).delete() { err in
          if let err = err {
            print("Error removing d!ocument: \(err)")
          } else {
            print("Document successfully removed!")
          }
        }
      } else {
        context.delete(taskArray[indexPath.row])
        do {
          try context.save()
        } catch {
          print("Error encoding array \(error)")
        }
      }
      self.taskArray.remove(at: indexPath.row)
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
