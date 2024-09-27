import ReSpringC

enum AlertMessageState {
    case respring, error
}

enum SpringBoardOrientation {
    case portrait, landscape
}

class ReSpring: UIViewController {
    
    //MARK: - Variables
    static let shared = ReSpring()
    private let prefs = TweakPreferences.preferences.settings!
    
    //MARK: - UIViewController
    override func _canShowWhileLocked() -> Bool {
        return true
    }
    
    //MARK: - Class Functions
    public class func respring() {
        respringDevice()
    }

    //MARK: - Functions
    func alertMessage(_ title: String, _ message: String, alertState: AlertMessageState) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        switch alertState {
        case .respring:
            let respringAction = UIAlertAction(title: "Respring", style: .destructive) { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.dismiss(animated: true) {
                    DispatchQueue.main.async {
                        ReSpring.respring()
                    }
                }
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.dismiss(animated: true)
            }
            
            alert.addAction(respringAction)
            alert.addAction(cancelAction)
            
            if prefs.customAlertMessage != "" && !prefs.customAlertMessage.isEmpty {
                alert.message = prefs.customAlertMessage
            }
            
        case .error:
            let dismissAction = UIAlertAction(title: "Dismiss", style: .destructive) { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.dismiss(animated: true)
            }
            
            alert.addAction(dismissAction)
        }
        
        respringWindow.rootViewController?.present(alert, animated: true)
    }
    
    func getRespringImagePath() -> String {
        let path: String = {
            var _path: String = "/var/mobile/Library/Preferences/com.pkgfiles.respringprefs/respringImage-IMG"
            if !FileManager.default.fileExists(atPath: _path) {
                _path = "/var/jb/var/mobile/Library/Preferences/com.pkgfiles.respringprefs/respringImage-IMG"
            }
            
            return _path
        }()
        
        return path
    }
}
