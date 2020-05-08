import UIKit
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Tasks {
    var uuid: String
    var text: String
    var priority: Int
}

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var signOutButton: UIBarButtonItem!
    
    var db: Firestore!
    var databaseHandle:DatabaseHandle?
    var taskArray = [Tasks]()
    var taskListener: ListenerRegistration!
    var currentUser: User!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentUser = Auth.auth().currentUser
        taskListener = db.collection("tasks").whereField("user_id", isEqualTo: currentUser.uid).addSnapshotListener { (querySnapshot, err) in
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        tableView.delegate = self
        tableView.dataSource = self
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
            db.collection("tasks").document(taskArray[indexPath.row].uuid).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
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
        taskListener.remove()
    }
    
    @IBAction func signOutTapped(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }
        
//        let vc = storyboard?.instantiateViewController(withIdentifier: "VC") as! ViewController
//        self.view.window?.rootViewController = vc
//        self.view.window?.makeKeyAndVisible()
        
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "VC") as! ViewController
        let navigationController = UINavigationController.init(rootViewController: viewController)
        
        self.view.window?.rootViewController = navigationController
        self.view.window?.makeKeyAndVisible()
    }
}
