import UIKit

extension UIViewController {
  /*! @fn showMessagePrompt
   @brief Displays an alert with an 'OK' button and a message.
   @param message The message to display.
   */
  func showMessagePrompt(_ message: String) {
    let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    alert.addAction(okAction)
    present(alert, animated: false, completion: nil)
  }
  
  /*! @fn showTextInputPromptWithMessage
   @brief Shows a prompt with a text field and 'OK'/'Cancel' buttons.
   @param message The message to display.
   @param completion A block to call when the user taps 'OK' or 'Cancel'.
   */
  func showTextInputPrompt(withMessage message: String,
                           completionBlock: @escaping ((Bool, String?) -> Void)) {
    let prompt = UIAlertController(title: nil, message: message, preferredStyle: .alert)
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
      completionBlock(false, nil)
    }
    weak var weakPrompt = prompt
    let okAction = UIAlertAction(title: "OK", style: .default) { _ in
      guard let text = weakPrompt?.textFields?.first?.text else { return }
      completionBlock(true, text)
    }
    prompt.addTextField(configurationHandler: nil)
    prompt.addAction(cancelAction)
    prompt.addAction(okAction)
    present(prompt, animated: true, completion: nil)
  }
}
