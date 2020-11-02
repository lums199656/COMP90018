//
//  AppDelegate.swift
//  Messager
//
//  Created by 陆敏慎 on 18/9/20.
//

import UIKit
import Firebase
import IQKeyboardManagerSwift
import LocalAuthentication

enum LocalAuthState {
    case loggedin, loggedout
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var localAuthState: LocalAuthState = .loggedout {
        didSet {
            print(localAuthState)
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        // _. Configure Keyboard Manager
//        IQKeyboardManager.shared.enable = true
//        IQKeyboardManager.shared.enableAutoToolbar = false
//        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        
        // _. Configure if seeding the Activity DB
        let _ = DBSeeding(true)
        
        // _. Configure Local Authentication (faceID...)
        let context = LAContext()
        
        // __. Check Hardware support
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {  // & for passing reference in swift..
            
            let reason = "Prove Yourself"
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { (success, error) in
                if success {
                    self.localAuthState = .loggedin
                } else {
                    print("Local Auth 1")
                    print(error?.localizedDescription ?? "💀Failed to authenticate.")
                }
            }
            
        } else {
            print("Local Auth 2")
            print(error?.localizedDescription ?? "💀Auth policy cannot be evaluated.")
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

