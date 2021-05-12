import UIKit
import CoreData
import Firebase
import FirebaseFirestore

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

  @IBOutlet weak var tableView: UITableView!
    
  var db: Firestore!
  var taskListener: ListenerRegistration!
  var currentUser: User?
  var handle: AuthStateDidChangeListenerHandle?
  var appDelegate = UIApplication.shared.delegate as! AppDelegate
  let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
  var taskArray: [Task] = []
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    handle = Auth.auth().addStateDidChangeListener { (auth, user) in
      if user != nil {
        self.currentUser = user
        self.taskListener = self.db.collection("tasks").whereField("userid", isEqualTo: self.currentUser?.uid ?? "").addSnapshotListener { (querySnapshot, err) in
          if let err = err {
            print("Error getting documents: \(err)")
          } else {
            self.taskArray.removeAll()
            for document in querySnapshot!.documents {
              let task = Task(context: self.context)
              task.text = document.data()["text"] as? String ?? ""
              task.priority = Int32(document.data()["priority"] as? Int ?? 0)
              task.userid = document.data()["user_id"] as? String ?? ""
              task.uuid = document.data()["uuid"] as? String ?? ""
              task.done = document.data()["done"] as? Bool ?? false
              self.taskArray.append(task)
            }
          }
          self.tableView.reloadData()
        }
      } else {
        self.currentUser = nil
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
    // fetch tasks from Core Data
    taskArray.removeAll()
    let request = Task.fetchRequest() as NSFetchRequest<Task>
    let predicate = NSPredicate(format: "userid == %@", currentUser?.uid ?? "")
    request.predicate = predicate
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
    let task = taskArray[indexPath.row]
    let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell")
    cell?.textLabel?.text = task.text ?? ""
    print(task)
    return cell!
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "gotoEdit" {
      let destinationVC = segue.destination as! EditViewController
      if let indexPath = sender as? NSIndexPath{
        let selectedTask = self.taskArray[indexPath.row]
        destinationVC.selectedTaskUuid = selectedTask.uuid ?? ""
      }
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
            print("Error removing document: \(err)")
          } else {
            print("Document successfully removed!")
          }
        }
      }
      context.delete(taskArray[indexPath.row])
      taskArray.remove(at: indexPath.row)
      appDelegate.saveContext()
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
