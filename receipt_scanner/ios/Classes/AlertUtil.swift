
@MainActor
enum AlertUtil {
  
  static func actionAlert(
    in vc: UIViewController,
    title: String,
    message: String,
    cancelTitle: String,
    actionTitle: String,
    action: @escaping () -> Void)
  {
    multiActionsAlert(
      in: vc,
      title: title,
      message: message,
      cancelTitle: cancelTitle,
      actions: [
        UIAlertAction(title: actionTitle, style: .default) { _ in
          action()
        }
      ])
  }
  
  static func multiActionsAlert(
    in vc: UIViewController,
    title: String,
    message: String,
    cancelTitle: String,
    actions: [UIAlertAction])
  {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    // seems to be UIKit behavior:
    // cancel button is ordered on the left for 2 buttons, on the bottom for 3 buttons.
    alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel) { _ in
      // nothing
      // sound is delayed, better not to play
    })

    for action in actions {
      alert.addAction(action)
    }
    
    
    vc.present(alert, animated: true, completion: nil)
  }
  
  
}
