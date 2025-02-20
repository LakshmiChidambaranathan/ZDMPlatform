//
//  ViewController.swift
//  ZDMPlatform
//
//  Created by lakshmi-12493 on 22/09/23.
//

import UIKit
import ZohoDeskPortalAPIKit
import ZohoDeskPortalTicket
//import ZPComponents
import ZohoDeskPlatformUIKit

class ViewController: UIViewController {
    
    @IBOutlet var launchButton : UIButton!
    @IBOutlet var customizeButton : UIMenuButton!
    @IBOutlet var infoLabel : UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    
    var jwtAPI: String { "https://jwtauth1minute-699218879.development.catalystserverless.com/server/JWT12Hrs/?jwt_secret=ij0zka4jjwEeHFuyUgjKCFDaCUs36qye9xNaWAvQ&user_token=%@&token_expiry=3000000" }
    
    @IBAction func logoutTapped(_ sender: UIButton) {
        self.showLogoutAlert()
    }
    @IBAction func launchScreen(_ sender: UIButton) {
        switch sender.titleLabel?.text {
        case loginText : signInTapped(sender)
        case accessTicket :
            if !ZohoDeskPortalKit.isUserLoggedIn { self.showAlert(with: "Kindly Login to Access your Tickets!"); return }
            ZDPortalTicket.show(style: style)
        default : break
        }
    }
    
    @IBAction func launchComponents(_ sender: UIButton) {
//        ZDPBuilderSDK.init(initial: "ZPHome", includeBinder: ZPComponentsProvider()) { (controller) in
//             DispatchQueue.main.async {
//                self.navigationController?.pushViewController(controller, animated: true)
//             }
//        }
    }
    
    lazy var blurView : UIView = {
        let bgView = UIView()
        bgView.backgroundColor = .systemGray6.withAlphaComponent(0.5)
        self.launchButton.addSubview(bgView)
        bgView.g_pinEdges()
        bgView.isHidden = true
        return bgView
    }()
    lazy var loader : UIActivityIndicatorView = {
        let loader = UIActivityIndicatorView()
        loader.tintColor = .white
        self.blurView.addSubview(loader)
        loader.g_pinEdges()
        loader.isHidden = true
        return loader
    }()
    
    let loginText : String = "Login"
    let accessTicket : String = "Access Tickets"
    lazy var signInProfile : ZDPortal.ZDPProfile? = nil
    var style : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetUp()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func initialSetUp() {
        self.infoLabel.text = "Users can now customize their ticket view!"
        self.logoutButton.isHidden = true
        self.customizeButton.setup(values: ["Default Style", "Custom Style 1", "Custom Style 2"], delegate: self)
        self.launchButton.setTitle(ZohoDeskPortalKit.isUserLoggedIn ? "Signing in...": loginText, for: .normal)
        ZohoDeskPortalKit.syncSettings { result in
            self.updateSignInValue()
        }
    }
    
    func updateSignInValue() {
        ZohoDeskPortalKit.getUserInformation { result in
            DispatchQueue.main.async {
                self.stop()
                switch result {
                case .success(let profile):
                    self.launchButton.setTitle(self.accessTicket, for: .normal)
                    self.signInProfile = profile
                    self.logoutButton.isHidden = false
                case .failure(_):
                    self.launchButton.setTitle(self.loginText, for: .normal)
                }
            }
        }
    }
    
    func fetchJWTTokenFromURL(userID: String, onCompletion handler: @escaping (String?) -> Void) {
         
//         guard let addOn = AutomationApp.AddOn(rawValue: ConfigurationDefaults.addOn) else { return }
         
         let Url = String(format: jwtAPI, userID)
         guard let serviceUrl = URL(string: Url) else { return }
         var request = URLRequest(url: serviceUrl)
         request.httpMethod = "GET"
         
         let session = URLSession.shared
         session.dataTask(with: request) { (data, response, error) in
             handler(data?.toString)
         }.resume()
     }
     
     func loginWithJWT(jwtToken: String?, onCompletion handler: @escaping (Bool) -> Void) {
         if let jwtToken = jwtToken {
             ZohoDeskPortalKit.login(withJWTToken: jwtToken) { isSuccess in
                 if isSuccess, let deviceID = UserDefaults.standard.value(forKey: "ZDPDemodeviceToken") as? String {
                     ZohoDeskPortalSDK.enablePushNotification(deviceToken: deviceID, mode: .sandbox)
                 }
                 
                 handler(isSuccess)
             }
         }else{
             handler(false)
         }
     }
    
    @objc private func signInTapped(_ sender: UIButton) {
        UISelectionFeedbackGenerator().selectionChanged()
        if !ZohoDeskPortalKit.isUserLoggedIn {
            sender.setTitle("Signing in...", for: .normal)
            let loginAlert = UIAlertController(title: "Login Using Email Id", message: nil, preferredStyle: .alert)
            loginAlert.view.tintColor = .systemBlue
            var emailTextField: UITextField? = nil
            loginAlert.addTextField { textField in
                emailTextField = textField
                textField.font = .systemFont(ofSize: 17.0)
                textField.placeholder = "Enter your email id"
                textField.text = /*"deskqa17@gmail.com"*/"vignesh.thillai@zohocorp.com"
            }
            let cancelAction = UIAlertAction(title: "Cancel",
                                             style: .destructive,
                                             handler: { _ in
                self.updateSignInValue()
            })
            loginAlert.addAction(cancelAction)
            
            let loginAction = UIAlertAction(title: "Login",
                                            style: .default,
                                            handler: { _ in
                guard let textField = emailTextField, let email = textField.text, email.isValidEmail else {
                    let message = "Enter a valid email id!"
                    loginAlert.setValue(NSMutableAttributedString(string: message, attributes: [NSAttributedString.Key.foregroundColor : UIColor.red, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]), forKey: "attributedMessage")
                    
                    self.present(loginAlert, animated: true, completion: nil)
                    return
                }
                self.start()
                
                self.fetchJWTTokenFromURL(userID: email, onCompletion: { [weak self] jwtToken in
                    guard let self = self else { return }
                    if let jwtToken = jwtToken {
                        ZohoDeskPortalKit.login(withJWTToken: jwtToken) { (isSucceed) in
                            self.updateSignInValue()
                        }
                    }
                })
            })
            
            loginAlert.addAction(loginAction)
            loginAlert.preferredAction = loginAction
            present(loginAlert, animated: true, completion: nil)
        }
    }
    
    private func loginASAP(with email: String = /*"deskqa17@gmail.com"*/"vignesh.thillai@zohocorp.com") {
        ZohoDeskPortalKit.login(withJWTToken: email) { (isSucceed) in
            if !(isSucceed) {
                self.showAlert(with: "Login failed")
            }
        }
    }
    
    private func showAlert(with message: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "Dismiss", style: .destructive) { (_) in
                alertController.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(dismissAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    private func showLogoutAlert() {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Logout", message: "Are you sure to logout \(self.signInProfile?.emailID)?", preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "No", style: .cancel) { (_) in
                alertController.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(dismissAction)
            let logoutAction = UIAlertAction(title: "Yes", style: .destructive) { _ in
                self.start()
                ZohoDeskPortalKit.logout { (isSucceed) in
                    DispatchQueue.main.async {
                        self.logoutButton.isHidden = true
                        self.updateSignInValue()
                    }
                }
            }
            alertController.addAction(logoutAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func start() {
        self.blurView.isHidden = false
        self.loader.isHidden = false
        self.loader.startAnimating()
    }
    func stop() {
        self.loader.stopAnimating()
        self.loader.isHidden = true
        self.blurView.isHidden = true
    }
    
}

extension ViewController : UIMenuButtonActionable {
    
    func didSelect(index: Int, title: String) {
        self.style = index
        self.start()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.stop()
        }
        
        self.infoLabel.alpha = .zero
        
        switch self.style {
        case 1, 2: self.infoLabel.text = "Ticket view is now customized with \(title)"
        default : self.infoLabel.text = "Users can now customize their ticket view!"
        }
        
        UIView.animate(withDuration: 0.75) {
            self.infoLabel.alpha = 1
        }
    }
}

extension UIView {
    func g_pinCenter(view: UIView? = nil) {
        g_pin(on: .centerX, view: view)
        g_pin(on: .centerY, view: view)
    }
    
    @discardableResult internal func g_pinEdges(view: UIView? = nil, priority: Float? = nil) -> (left: NSLayoutConstraint?, right: NSLayoutConstraint?, top: NSLayoutConstraint?, bottom: NSLayoutConstraint?) {
        let top = g_pin(on: .top, view: view, priority: priority)
        let bottom = g_pin(on: .bottom, view: view, priority: priority)
        let left = g_pin(on: .left, view: view, priority: priority)
        let right = g_pin(on: .right, view: view, priority: priority)
        return (left, right, top, bottom)
    }
    @discardableResult internal func g_pin(on type1: NSLayoutConstraint.Attribute,
                                           view: UIView? = nil,
                                           on type2: NSLayoutConstraint.Attribute? = nil,
                                           constant: CGFloat = 0,
                                           relatedBy relation: NSLayoutConstraint.Relation = .equal,
                                           priority: Float? = nil) -> NSLayoutConstraint? {
        guard let view = view ?? superview else {
            return nil
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        let type2 = type2 ?? type1
        let constraint = NSLayoutConstraint(item: self, attribute: type1,
                                            relatedBy: relation,
                                            toItem: view, attribute: type2,
                                            multiplier: 1, constant: constant)
        if let priority = priority {
            constraint.priority = UILayoutPriority.init(priority)
        } else {
            constraint.priority = UILayoutPriority.init(999)
        }
        
        constraint.isActive = true
        
        return constraint
    }
}




protocol UIMenuButtonActionable: AnyObject {
    
    func didSelect(index: Int, title: String)
}

class UIMenuButton: UIButton {
    
    private var actions: [String] = []
    private weak var delegate: UIMenuButtonActionable?
    
    func setup(values: [String], delegate: UIMenuButtonActionable?) {
        
        self.delegate = delegate
        self.actions = values
        self.prepare()
    }
    
    func prepare() {
        if #available(iOS 14.0, *) {
            let actions = actions.map({
                let action = UIAction(title: $0) { [weak self] action in
                    guard let self else { return }
                    if let index = self.actions.firstIndex(of: action.title) {
                        self.delegate?.didSelect(index: index, title: action.title)
                    }
                }
                return action
            })
            
            let menu = UIMenu(title: "", children: actions)
            self.showsMenuAsPrimaryAction = true
            self.menu = menu
        }
        
        self.addTarget(self, action: #selector(onTap), for: .touchUpInside)
    }
    
    @objc
    private func onTap() {
        let actionsheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        actions.forEach({
            actionsheet.addAction(
                UIAlertAction(title: $0, style: .default) { [weak self] action in
                    guard let self else { return }
                    if let title = action.title, let index = self.actions.firstIndex(of: title) {
                        self.delegate?.didSelect(index: index, title: title)
                    }
                })
        })
        actionsheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.getTopController()?.present(actionsheet, animated: true)
    }
    
    private func getTopController() -> UIViewController? {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return nil
    }
}


extension Data {
    var toString : String {
        if let string = String(data: self, encoding: .utf8) {
            return string
        } else {
            return ""
        }
    }
}
