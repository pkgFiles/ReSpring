import UIKit

struct SettingsModel: Codable {
    var isEnabled: Bool = false
    var isEnabledZeppelinMode: Bool = false
    var isEnabledLockscreen: Bool = true
    var isAlertMessageEnabled: Bool = true
    var customAlertMessage: String = ""
    var xPosition: Float = 0.0
    var yPosition: Float = 0.0
    var imageSize: Int = 1
}
