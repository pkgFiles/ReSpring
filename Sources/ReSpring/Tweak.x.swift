import Orion
import ReSpringC

//MARK: - Variables
var respringWindow: RespringWindow!
var statusBarFrame: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
var activeSpringBoardOrientation: SpringBoardOrientation = .portrait
var isScreenOn: Bool = false
var isLockscreenActive: Bool = false
var isHomescreenActive: Bool = false
var isApplicationActive: Bool = false

//MARK: - HookGroups
struct TweakEnabled: HookGroup { let isTweakEnabled: Bool }
struct DeviceNotched: HookGroup { let hasNotch: Bool }

//MARK: - Functions
// Start Tweak
// Load Preferences
struct LoadingTweak: Tweak {
    
    init() {
        do {
            remLog("Preferences Loading...")
            try TweakPreferences.preferences.loadPreferences()
        } catch let error as NSError {
            remLog(error.localizedDescription)
        }
        
        // This is important and many Tweak Devs forget that...
        // If the Tweak is disabled, there shouldn't be any Hooks at all!
        let respringTweakHook = TweakEnabled(isTweakEnabled: TweakPreferences.preferences.settings.isEnabled)
        if respringTweakHook.isTweakEnabled {
            remLog("Tweak is Enabled! :)")
            respringTweakHook.activate()
            
            DispatchQueue.main.async {
                let respringExtraHook = DeviceNotched(hasNotch: UIDevice.current.hasNotch)
                if respringExtraHook.hasNotch {
                    respringExtraHook.activate()
                }
            }
        } else {
            remLog("Tweak is Disabled! :(")
            return
        }
    }
}

class SpringBoardHook: ClassHook<SpringBoard> {
    
    typealias Group = TweakEnabled
    
    func applicationDidFinishLaunching(_ application: AnyObject) {
        orig.applicationDidFinishLaunching(application)
        
        if Group.isActive {
            respringWindow = RespringWindow(frame: UIScreen.main.bounds)
        }
    }
    
    func isShowingHomescreen() -> Bool {
        isHomescreenActive = orig.isShowingHomescreen()
        
        if !isLockscreenActive && !isHomescreenActive {
            isApplicationActive = true
        } else { isApplicationActive = false }
        
        return isHomescreenActive
    }
    
    func activeInterfaceOrientation() -> Int64 {
        switch orig.activeInterfaceOrientation() {
        case 3, 4: activeSpringBoardOrientation = .landscape
        default: activeSpringBoardOrientation = .portrait
        }
        
        // This gets called very often.
        // Best state to check all ReSpring behaviours with just a single Observer...
        NotificationCenter.default.post(name: NSNotification.Name("com.pkgFiles.handleSpringBoard"), object: nil)
        return orig.activeInterfaceOrientation()
    }
}

class DeviceBacklightHook: ClassHook<SBBacklightController> {
    
    typealias Group = TweakEnabled
    
    func screenIsOn() -> Bool {
        isScreenOn = orig.screenIsOn()
        return isScreenOn
    }
}

class LockscreenHook: ClassHook<CSCoverSheetViewController> {
    
    typealias Group = TweakEnabled
    
    func viewWillAppear(_ animated: Bool) {
        orig.viewWillAppear(animated)
        isLockscreenActive = true
    }
    
    func viewWillDisappear(_ animated: Bool) {
        orig.viewWillDisappear(animated)
        isLockscreenActive = false
    }
}

class UIStatusBarHook: ClassHook<_UIStatusBar> {
    
    typealias Group = TweakEnabled
    
    func initWithStyle(_ style: Int64) {
        orig.initWithStyle(style)
        
        // Get current frame from StatusBar
        statusBarFrame = target.frame
    }
}

class SBStatusBarItemsHook: ClassHook<SBStatusBarStateAggregator> {
    
    typealias Group = DeviceNotched
    
    func _updateLocationItem() {
        if TweakPreferences.preferences.settings.isEnabledZeppelinMode {
            return
        } else { orig._updateLocationItem() }
    }
}

class StatusBarCellularItemHook: ClassHook<_UIStatusBarCellularItem> {
    
    typealias Group = DeviceNotched
    
    func serviceNameView() -> _UIStatusBarStringView {
        if TweakPreferences.preferences.settings.isEnabledZeppelinMode {
            switch TweakPreferences.preferences.settings.isEnabledLockscreen {
            case true:
                return _UIStatusBarStringView()
                
            case false:
                if !isLockscreenActive && isHomescreenActive {
                    return _UIStatusBarStringView()
                }
            }
        }
        
        return orig.serviceNameView()
    }
}

class StatusBarTimeItemHook: ClassHook<_UIStatusBarTimeItem> {
    
    typealias Group = DeviceNotched
    
    func shortTimeView() -> _UIStatusBarStringView {
        if TweakPreferences.preferences.settings.isEnabledZeppelinMode {
            return _UIStatusBarStringView()
        }
        
        return orig.shortTimeView()
    }
}

class SBStatusBarPillViewHook: ClassHook<_UIStatusBarPillView> {
    
    typealias Group = DeviceNotched
    // alpha can changes its value to 1, if the pill has recently shown and an app has been opened...
    // for this case we need to extra check if superview != nil
    func layoutSubviews() {
        orig.layoutSubviews()
        
        if TweakPreferences.preferences.settings.isEnabledZeppelinMode {
            if target.alpha == 1 && target.superview != nil {
                UIView.animate(withDuration: 0.5) {
                    respringWindow.rootViewController?.view.alpha = 0
                }
            } else {
                UIView.animate(withDuration: 1.0) {
                    respringWindow.rootViewController?.view.alpha = 1
                }
            }
        }
    }
}
