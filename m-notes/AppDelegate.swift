//
//  AppDelegate.swift
//  m-notes
//
//  Created by Mateo Garcia on 1/20/19.
//  Copyright © 2019 wavy-project. All rights reserved.
//

import UIKit
import Buglife
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Buglife.shared().start(withEmail: "kilouett.dev@gmail.com")
        Buglife.shared().invocationOptions = [.shake, .screenshot]
        // To present manually: Buglife.shared().presentReporter()
        
        if let keys = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Keys", ofType: "plist")!) {
            let configuration = ParseClientConfiguration {
                
                // Local staging
                // $0.applicationId = keys["ParseStagingLocalApplicationID"] as? String
                // $0.clientKey = keys["ParseStagingLocalClientKey"] as? String
                // $0.server = keys["ParseStagingLocalServerURL"] as! String
                
                // Staging
                // $0.applicationId = keys["ParseStagingApplicationID"] as? String
                // $0.clientKey = keys["ParseStagingClientKey"] as? String
                // $0.server = keys["ParseStagingServerURL"] as! String
                
                /*~*~*~*~*~*~*~* CRITICAL SECTION *~*~*~*~*~*~*~*/
                
                /*********** ENABLE BEFORE APP DEPLOY ***********/
                $0.applicationId = keys["ParseApplicationID"] as? String
                // $0.clientKey = keys["ParseClientKey"] as? String
                $0.server = keys["ParseServerURL"] as! String
                
                /*~*~*~*~*~*~* END CRITICAL SECTION *~*~*~*~*~*~*/
            }
            Parse.enableLocalDatastore()
            Parse.initialize(with: configuration)
        } else {
            print("Error: Unable to load Keys.plist.")
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

extension AppDelegate {
    private func present(_ viewController: UIViewController, animated: Bool) {
        if animated {
            viewController.modalTransitionStyle = .crossDissolve
            window?.rootViewController?.present(viewController, animated: true, completion: {
                self.window?.rootViewController = viewController
                // viewController.dismiss(animated: false, completion: nil)
            })
        } else {
            // Does exactly the same as arrow in storyboard. ("100% parity." --Tim Lee)
            window?.rootViewController = viewController
        }
    }
    
    func presentSignUpViewController(animated: Bool, email: String? = nil, password: String? = nil, giftedPlanID: String? = nil) {
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        let signupNC = storyboard.instantiateViewController(withIdentifier: "SignUpNC") as! UINavigationController
        let signupVC = signupNC.viewControllers[0] as! SignUpViewController
        signupVC.emailAddress = email
        signupVC.password = password
        signupVC.giftedPlanID = giftedPlanID
        present(signupNC, animated: animated)
    }
    
    func presentLoginViewController(animated: Bool, email: String? = nil, password: String? = nil) {
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        let loginNC = storyboard.instantiateViewController(withIdentifier: "LoginNC") as! UINavigationController
        let loginVC = loginNC.viewControllers[0] as! LoginViewController
        loginVC.emailAddress = email
        loginVC.password = password
        present(loginNC, animated: animated)
    }
    
    func presentHomeViewController(animated: Bool) {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let homeTabBarNC = storyboard.instantiateViewController(withIdentifier: "HomeNC") as! UINavigationController
        present(homeTabBarNC, animated: animated)
    }
}
