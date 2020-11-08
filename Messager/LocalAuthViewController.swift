//
//  LocalAuthViewController.swift
//  Messager
//
//  Created by Boyang Zhang on 2/11/20.
//

import UIKit
import LocalAuthentication

enum LocalAuthState {
    case loggedin, loggedout
}

var localAuthState: LocalAuthState = .loggedout {
    didSet {
        print("LOCAL AUTH Global")
        if localAuthState == .loggedin {
            
        }
    }
}


class LocalAuthViewController: UIViewController {
    
    @IBOutlet weak var unlockButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        triggerBioAuth()
    }
    
    func setupUI() {
        unlockButton.cornerRadius = 20
    }
    
    // MARK:- IBActions
    @IBAction func unlockButtonTapped(_ sender: UIButton) {
        triggerBioAuth()
    }
    
    @IBAction func logOutButtonTapped(_ sender: UIButton) {
        FirebaseUserListener.shared.logOutCurrentUser{ (error) in
            if error == nil {
                let loginView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "loginView")
                
                DispatchQueue.main.async {
                    loginView.modalPresentationStyle = .fullScreen
                    self.present(loginView, animated: true, completion: nil)
                }
            }
        }
    }
    
    func triggerBioAuth() {
        // _. Configure Local Authentication (faceID...)
        let context = LAContext()
        
        // __. Check Hardware support
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {  // & for passing reference in swift..
            
            let reason = "Prove Yourself"
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { (success, error) in
                if success {
                    localAuthState = .loggedin
                    
                    // Move to the main thread because a state update triggers UI changes.
                    DispatchQueue.main.async { [unowned self] in
                        
                        let localAuthVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "rootTabVC")
                        localAuthVC.modalPresentationStyle = .fullScreen
                        self.present(localAuthVC, animated: false, completion: nil)
                    }
                    
                } else {
                    print("🔐Local Auth 1")
                    print(error?.localizedDescription ?? "🔐Failed to authenticate.")
                }
            }
            
        } else {
            print("🔐Local Auth 2")
            print(error?.localizedDescription ?? "🔐Auth policy cannot be evaluated.")
        }
    }
}
