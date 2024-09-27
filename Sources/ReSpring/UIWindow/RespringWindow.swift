import ReSpringC

class RespringWindow: UIWindow {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        windowLevel = UIWindow.Level.alert - 1
        windowScene = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.windowScene
        isHidden = false
        
        let vc = TapToRespringViewController()
        rootViewController = vc
        rootViewController?.view.frame = frame
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func makeKeyAndVisible() {
        super.makeKeyAndVisible()
    }
    
    override func _shouldCreateContextAsSecure() -> Bool {
        return true
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == self || view == self.rootViewController?.view ? nil : view
    }
}
