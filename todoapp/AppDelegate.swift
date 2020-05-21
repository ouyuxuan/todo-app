import UIKit
import Firebase
import FirebaseFirestore
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions:           [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    FirebaseApp.configure()
    Firestore.firestore()
    GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
    GIDSignIn.sharedInstance().delegate = self
    return true
  }

  @available(iOS 9.0, *)
  func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
    return GIDSignIn.sharedInstance().handle(url)
  }

  // signin handler
  func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
    guard let controller = GIDSignIn.sharedInstance().presentingViewController as? AuthViewController else { return }
    if let error = error {
      if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
        print("The user has not signed in before or they have since signed out.")
      } else {
        print("\(error.localizedDescription)")
      }
      
      NotificationCenter.default.post(name: Notification.Name(rawValue: "ToggleAuthUINotification"), object: nil, userInfo: nil)
        return
      }
        
      // Perform any operations on signed in user here.
    let userId = user.userID                  // For client-side use only!
    let givenName = user.profile.givenName
    let familyName = user.profile.familyName
    let fullName = user.profile.name
    let email = user.profile.email
    
    guard let authentication = user.authentication else { return }
    let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                   accessToken: authentication.accessToken)
    controller.firebaseLogin(credential, userId, email, givenName, familyName)
    NotificationCenter.default.post(
      name: Notification.Name(rawValue: "ToggleAuthUINotification"),
      object: nil,
      userInfo: ["statusText": "Signed in user:\n\(fullName!)"])
  }
    
  // disconnect handler
  func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
    // Perform any operations when the user disconnects from app here.

    NotificationCenter.default.post(
      name: Notification.Name(rawValue: "ToggleAuthUINotification"),
      object: nil,
      userInfo: ["statusText": "User has disconnected."])
  }

  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur   for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
}
