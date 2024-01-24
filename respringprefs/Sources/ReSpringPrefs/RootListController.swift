import Preferences
import ReSpringPrefsC
import GcUniversal

class RootListController: PSListController {
    
    let headerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 350))
    
    override init(forContentSize contentSize: CGSize) {
        super.init(forContentSize: contentSize)
        
        // Add respring button
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Respring", style: .plain, target: self, action: #selector(respringTask))

        if let imageData = ReSpringPrefs.shared.getBannerImage() {
            // Add banner image...
            let headerImageView = UIImageView()
            headerImageView.contentMode = .scaleAspectFit
            headerImageView.translatesAutoresizingMaskIntoConstraints = false
            headerImageView.image = imageData
            
            headerView.addSubview(headerImageView)
            
            NSLayoutConstraint.activate([
                headerImageView.topAnchor.constraint(equalTo: headerView.topAnchor),
                headerImageView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
                headerImageView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
                headerImageView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            ])
        } else { headerView.frame = CGRect(x: 0, y: 0, width: 0, height: 0) }
    }
    
    //MARK: - Actions
    @objc func openGithub() {
        if let url = URL(string: "https://github.com/pkgFiles") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @objc func removeUserImage() {
        let folderPath: String = ReSpringPrefs.shared.getRespringImageFolderPath()
        
        if FileManager().fileExists(atPath: folderPath) {
            do {
                try FileManager().removeItem(atPath: folderPath)
                self.reload()
            } catch let error as NSError {
                remLog(error.localizedDescription)
            }
        } else {
            let alert = UIAlertController(title: "Error", message: "You have not selected an image...", preferredStyle: .alert)
            
            let dismissAction = UIAlertAction(title: "Dismiss", style: .destructive) { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.dismiss(animated: true)
            }
            
            alert.addAction(dismissAction)
            present(alert, animated: true)
        }
    }
    
    @objc func removePosition() {
        let filePath: String = "/var/mobile/Library/Preferences/com.pkgfiles.respringprefs.plist"
        
        if FileManager().fileExists(atPath: filePath) {
            setPreferenceValue(0.0, specifier: specifier(forID: "xPosition"))
            setPreferenceValue(0.0, specifier: specifier(forID: "yPosition"))
            self.reload()
        }
    }
    
    //MARK: - Functions
    @objc func respringTask() {
        DispatchQueue.main.async {
            ReSpringPrefs.respring()
        }
    }
    
    //MARK: - Table view
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.tableHeaderView = headerView
        return super.tableView(tableView, cellForRowAt: indexPath)
    }
    
    //MARK: - Required
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
}
