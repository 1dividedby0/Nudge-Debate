//
//  AppDelegate.swift
//  debate.com
//
//  Created by Dhruv Mangtani on 11/26/15.
//  Copyright © 2015 dhruv.mangtani. All rights reserved.
//

import UIKit
import Parse
import Bolts
import FBSDKCoreKit

var newData = false

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        // ROLLOUT SETUP
        //Rollout.setup(withKey: "56bbf366cc626037300599b8")
        
        
        
        // FACEBOOK SETUP
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // PARSE SETUP
        Parse.enableLocalDatastore()
        
        let config = ParseClientConfiguration(block: {
            (ParseMutableClientConfiguration) -> Void in
            ParseMutableClientConfiguration.applicationId = "QPhr2OMkucMziOB8pCbLc2Q977I96K9HkJHx5wsV"
            ParseMutableClientConfiguration.clientKey = "iMq57OxwsNW1uy7ZXUr82MZ2nFEywIsHWyigg17T"
            ParseMutableClientConfiguration.server = "http://parseserver-cxapn-env.us-east-1.elasticbeanstalk.com/parse"
        })
        
        Parse.initialize(with: config)
        
        if application.applicationState != UIApplicationState.background{
            let preBackgroundPush = !application.responds(to: "backgroundRefreshStatus")
            let oldPushHandlerOnly = !self.responds(to: "application:didReceiveRemoteNotification:fetchCompletionHandler:")
            var pushPayLoad = true
            
            if let options = launchOptions{
                //pushPayLoad = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil
            }
            if preBackgroundPush || oldPushHandlerOnly || pushPayLoad {
                PFAnalytics.trackAppOpened(launchOptions: launchOptions)
            }
        }
        let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        // automatically signs user in
        if PFUser.current() != nil{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if PFUser.current()!.object(forKey: "side") != nil{
                let initialViewController = storyboard.instantiateViewController(withIdentifier: "revealController") as! SWRevealViewController
                self.window?.rootViewController = initialViewController
                self.window?.makeKeyAndVisible()
            }else{
                let initialViewController = storyboard.instantiateViewController(withIdentifier: "chooseSide") as! ChooseSideViewController
                self.window?.rootViewController = initialViewController
                self.window?.makeKeyAndVisible()
            }
        }
        return true
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let installation = PFInstallation.current()
        installation!.setDeviceTokenFrom(deviceToken)
        installation!.saveInBackground()
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010{
            print("Push Notifications not supported by IOS sim")
        }else{
             print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PFPush.handle(userInfo)
        if application.applicationState == UIApplicationState.inactive{
            PFAnalytics.trackAppOpened(withRemoteNotificationPayload: userInfo)
        }else if application.applicationState == UIApplicationState.active{
            newData = true
        }
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

