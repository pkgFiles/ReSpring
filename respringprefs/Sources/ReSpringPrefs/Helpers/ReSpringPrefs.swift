import ReSpringPrefsC

class ReSpringPrefs: UIViewController {
    
    //MARK: - Variables
    static let shared = ReSpringPrefs()
    
    private let imagePath: String = {
        var path: String = "/var/jb/Library/PreferenceBundles/ReSpringPrefs.bundle/banner.png"
            if !FileManager.default.fileExists(atPath: path) {
                path = "/Library/PreferenceBundles/ReSpringPrefs.bundle/banner.png"
            }
            
            return path
        }()
    
    //MARK: - Class Functions
    public class func respring() {
        respringDevice()
    }
    
    //MARK: - Functions
    func getBannerImage() -> UIImage? {
        guard let image = UIImage(contentsOfFile: imagePath) else { return nil }
        return image
    }
    
    func getRespringImageFolderPath() -> String {
        let path: String = {
            var _path: String = "/var/mobile/Library/Preferences/com.pkgfiles.respringprefs"
            if !FileManager.default.fileExists(atPath: _path) {
                _path = "/var/jb//var/mobile/Library/Preferences/com.pkgfiles.respringprefs"
            }
            
            return _path
        }()
        
        return path
    }
}
