import Foundation

class TweakPreferences {
    var settings: SettingsModel!
    static let preferences = TweakPreferences()
    private let path = "/var/mobile/Library/Preferences/com.pkgfiles.respringprefs.plist"
    
    func createPreferences() {
        let mirror = Mirror(reflecting: SettingsModel())
        var data: [String: Any] = [:]
        
        for child in mirror.children {
            guard let key = child.label else { return }
            data.updateValue(child.value, forKey: key)
        }
        
        let defaultSettings = NSDictionary(dictionary: data)
        defaultSettings.write(toFile: path, atomically: true)
        
        do {
            try loadPreferences()
        } catch let error as NSError {
            remLog(error.localizedDescription)
        }
    }
    
    func loadPreferences() throws {
        if let data = FileManager().contents(atPath: path) {
            self.settings = try PropertyListDecoder().decode(SettingsModel.self, from: data)
            remLog(self.settings!)
        } else {
            if !FileManager().fileExists(atPath: path) {
                remLog("Preferences don't exist... Creating...")
                createPreferences()
            }
        }
    }
}
