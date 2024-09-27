import ReSpringC

class TapToRespringViewController: UIViewController {
    
    //MARK: - Variables
    private let defaultImagePath: String = {
        var path: String = "/var/jb/Library/PreferenceBundles/ReSpringPrefs.bundle/ReSpring.png"
        if !FileManager.default.fileExists(atPath: path) {
            path = "/Library/PreferenceBundles/ReSpringPrefs.bundle/ReSpring.png"
        }
        
        return path
    }()
    
    private let isUserImageSet: Bool = {
        let image: UIImage?
        let path: String = ReSpring.shared.getRespringImagePath()
        
        if FileManager().fileExists(atPath: path) {
            image = UIImage(contentsOfFile: path)
            return true
        } else {
            return false
        }
    }()
    
    let respringImageFrame: CGRect = {
        var _respringImageFrame = CGRect(x: 0, y: 0, width: 0, height: 0)
        var respringOrigin = CGPoint(x: 0, y: 0)
        var respringSize = CGSize(width: 0, height: 0)
        let currentAppeareance: Int = TweakPreferences.preferences.settings.imageSize
        
        switch currentAppeareance {
        case 0: //Small
            respringSize = CGSize(width: 25, height: 25)
            respringOrigin = CGPoint(x: respringSize.width + 25, y: 5)
            _respringImageFrame = CGRect(origin: respringOrigin, size: respringSize)
            
        case 1: //Medium
            respringSize = CGSize(width: 35, height: 35)
            respringOrigin = CGPoint(x: respringSize.width + 10, y: 0)
            _respringImageFrame = CGRect(origin: respringOrigin, size: respringSize)
            
        case 2: //Large
            respringSize = CGSize(width: 45, height: 45)
            respringOrigin = CGPoint(x: respringSize.width - 5, y: -5)
            _respringImageFrame = CGRect(origin: respringOrigin, size: respringSize)
            
        default: break
        }
        
        return _respringImageFrame
    }()
    
    private let prefs = TweakPreferences.preferences.settings!
    static let shared = TapToRespringViewController()
    let respringView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    let respringImageView: UIImageView = UIImageView()
    
    //MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupObservers()
        setupRespringView()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if prefs.isEnabledZeppelinMode && UIDevice.current.hasNotch {
            //Change frame in ZeppelinMode for notched Devices
            respringView.frame = CGRect(x: respringImageFrame.origin.x + CGFloat(prefs.xPosition),
                                        y: respringImageFrame.origin.y + CGFloat(prefs.yPosition),
                                        width: respringImageFrame.width,
                                        height: respringImageFrame.height)
        } else {
            // Default frame for notched & legacy Devices
            respringView.frame = CGRect(x: (view.frame.maxX - respringImageFrame.width) + CGFloat(prefs.xPosition),
                                        y: ((statusBarFrame.height / 2) + respringImageFrame.origin.y) + CGFloat(prefs.yPosition),
                                        width: respringImageFrame.width,
                                        height: respringImageFrame.height)
        }
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override func _canShowWhileLocked() -> Bool {
        return true
    }
    
    //MARK: - Functions
    func setupRespringView() {
        // Creating Elements
        let recognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(respringTask))
        
        // UIImageView
        if let image = getRespringImage() {
            remLog("userImage?: \(isUserImageSet)")
            respringImageView.image = image
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                ReSpring.shared.alertMessage("Error: No Image Found", "Image can't be loaded... \n\nReinstall the Tweak and try again, otherwise contact me on Twitter: @pkgFiles", alertState: .error)
                return self.view.removeFromSuperview()
            }
        }
        
        respringImageView.contentMode = .scaleAspectFill
        respringImageView.isUserInteractionEnabled = false
        respringImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // UIView
        respringView.frame = respringImageFrame
        respringView.addGestureRecognizer(recognizer)
        respringView.addSubview(respringImageView)
        
        // Add + Activate constraints based on respringView
        NSLayoutConstraint.activate([
            respringImageView.centerXAnchor.constraint(equalTo: respringView.centerXAnchor),
            respringImageView.centerYAnchor.constraint(equalTo: respringView.centerYAnchor),
            respringImageView.widthAnchor.constraint(equalToConstant: respringView.frame.width / 2),
            respringImageView.heightAnchor.constraint(equalToConstant: respringView.frame.height / 2)
        ])
        
        // Add to View
        view.addSubview(respringView)
    }
    
    func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleSpringBoard), name: NSNotification.Name("com.pkgFiles.handleSpringBoard"), object: nil)
    }
    
    @objc func respringTask() {
        if prefs.isAlertMessageEnabled {
            ReSpring.shared.alertMessage("ReSpring?", "Are you sure you want to respring your device?", alertState: .respring)
        } else {
            DispatchQueue.main.async {
                ReSpring.respring()
            }
        }
    }
    
    func getRespringImage() -> UIImage? {
        guard let defaultImage = UIImage(contentsOfFile: defaultImagePath) else { return nil }
        var image: UIImage = defaultImage
        let path: String = ReSpring.shared.getRespringImagePath()
        
        if isUserImageSet {
            guard let imageData = NSData(contentsOf: URL(fileURLWithPath: path)) else { return defaultImage }
            let imageFormat = imageData.imageFormat
            
            switch imageFormat {
            case .Unknown:
                // This should never happen...
                return defaultImage
                
            case .GIF:
                // Use a loop to make .gif compatible...
                remLog("imageFormat: \(imageFormat) (A loop is required...)")
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: path, isDirectory: true))
                    image = UIImage.gif(data: data)!
                } catch let error as NSError {
                    remLog(error.localizedDescription)
                }
                
            default:
                // Set the image without any loop...
                remLog("imageFormat: \(imageFormat) (There shouldn't be a loop...)")
                image = UIImage(contentsOfFile: path) ?? defaultImage
            }
        }
        
        return image
    }
    
    @objc func handleSpringBoard() {
        if isApplicationActive && isScreenOn {
            if prefs.isEnabledLockscreen {
                if isLockscreenActive && activeSpringBoardOrientation == .portrait { reassignImageToMemory() }
            }
            if !isLockscreenActive && !isHomescreenActive {
                activeSpringBoardOrientation == .landscape ? clearImageFromMemory() : reassignImageToMemory()
            }
        } else {
            if !isScreenOn {
                clearImageFromMemory()
            } else {
                if prefs.isEnabledLockscreen {
                    isScreenOn ? reassignImageToMemory() : clearImageFromMemory()
                } else {
                    isScreenOn && isLockscreenActive ? clearImageFromMemory() : reassignImageToMemory()
                }
            }
        }
    }
    
    func clearImageFromMemory() {
        DispatchQueue.main.async {
            if self.respringImageView.image != nil && self.view.alpha == 1 {
                remLog("Clear Image from Memory...")
                self.respringImageView.image = nil
                self.view.alpha = 0
            }
        }
    }
    
    func reassignImageToMemory() {
        DispatchQueue.main.async {
            if self.respringImageView.image == nil && self.view.alpha == 0 {
                remLog("Reassign Image to Memory...")
                UIView.animate(withDuration: 0.5) {
                    self.respringImageView.image = self.getRespringImage()
                    self.view.alpha = 1
                }
            }
        }
    }
}
