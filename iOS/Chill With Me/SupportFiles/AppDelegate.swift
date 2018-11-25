//
//  AppDelegate.swift
//  Chill With Me
//
//  Created by Phillip Hoang on 2018-08-22.
//  Copyright © 2018 IC Heart Technologies. All rights reserved.
//

import UIKit
import GoogleSignIn
import StitchCore
import StitchCoreSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var window: UIWindow?
    var navigationController: UINavigationController?
    var accountController = AccountController.shared
    var backgroundFetchController: BackgroundFetchController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        GIDSignIn.sharedInstance().clientID = "REDACTED"
        GIDSignIn.sharedInstance().serverClientID = "REDACTED"
        GIDSignIn.sharedInstance().delegate = self
        
        // Initialize Stitch App Client
        do {
            _ = try Stitch.initializeDefaultAppClient(
                withClientAppID: "REDACTED"
            )
        } catch {}
        
        // Setup background fetch controller
        self.backgroundFetchController = BackgroundFetchController(client: Stitch.defaultAppClient!, accountController: accountController)
        UIApplication.shared.setMinimumBackgroundFetchInterval(180)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        if let window = window {
            let mainView = MainScreenViewController()
            
            navigationController = UINavigationController(rootViewController: mainView)

            window.rootViewController = navigationController
            window.makeKeyAndVisible()
        }

        return true
    }
    
    // For background fetching
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if UIApplication.shared.backgroundRefreshStatus == .available {
            self.backgroundFetchController?.fetch(completionHandler)
        }
    }
    
    // For GoogleSignIn, do not touch
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url as URL?,
                                                 sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                 annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }
    
    func sign(_ signIn : GIDSignIn!, didSignInFor user : GIDGoogleUser!, withError error : Error!) {
        if error != nil {
            GIDSignIn.sharedInstance().disconnect()
            GIDSignIn.sharedInstance().signOut()
        } else {
            // Perform any operation on signed in user here.
            var googleCredential: GoogleCredential
            if user.serverAuthCode != nil {
                googleCredential = GoogleCredential.init(withAuthCode: user.serverAuthCode)
                
                Stitch.defaultAppClient!.auth.login(withCredential: googleCredential) { result in
                    switch result {
                    case .success:
                        // Reload tableview on main menu screen
                        // https://stackoverflow.com/questions/32348122/pass-error-parameter-in-swift
                        let err : Error? = nil
                        GIDSignIn.sharedInstance().uiDelegate.sign?(inWillDispatch: GIDSignIn.sharedInstance(), error: err)
                    case .failure(_):                      
                        let alert = UIAlertController(title: "Error", message: "Failed to sign in", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                        
                        GIDSignIn.sharedInstance().disconnect()
                        GIDSignIn.sharedInstance().signOut()
                    }
                }
                
            } else {
                if Stitch.defaultAppClient!.auth.isLoggedIn == false {
                    GIDSignIn.sharedInstance().disconnect()
                    GIDSignIn.sharedInstance().signOut()
                }
            } 
        }
    }
    
    // GOOGLE DISCONNECT/SIGN OUT
    func sign(_ signIn : GIDSignIn!, didDisconnectWith user : GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        _ = accountController.deleteProfileOnFile()
        
        Stitch.defaultAppClient!.auth.logout { (result: StitchResult<Void>) in
            self.accountController.manuallySignedOut = true
            GIDSignIn.sharedInstance().uiDelegate.sign?(inWillDispatch: GIDSignIn.sharedInstance(), error: error)
        }
        
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

