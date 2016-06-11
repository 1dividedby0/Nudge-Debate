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

var newData = false

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        Rollout.setupWithKey("56bbf366cc626037300599b8")
        
        Parse.enableLocalDatastore()
        Parse.setApplicationId("QPhr2OMkucMziOB8pCbLc2Q977I96K9HkJHx5wsV",
            clientKey: "iMq57OxwsNW1uy7ZXUr82MZ2nFEywIsHWyigg17T")
        if application.applicationState != UIApplicationState.Background{
            let preBackgroundPush = !application.respondsToSelector("backgroundRefreshStatus")
            let oldPushHandlerOnly = !self.respondsToSelector("application:didReceiveRemoteNotification:fetchCompletionHandler:")
            var pushPayLoad = false
            if let options = launchOptions{
                pushPayLoad = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil
            }
            if preBackgroundPush || oldPushHandlerOnly || pushPayLoad {
                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            }
        }
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        // automatically signs user in
        if PFUser.currentUser() != nil{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if PFUser.currentUser()!.objectForKey("side") != nil{
                let initialViewController = storyboard.instantiateViewControllerWithIdentifier("revealController") as! SWRevealViewController
                self.window?.rootViewController = initialViewController
                self.window?.makeKeyAndVisible()
            }else{
                let initialViewController = storyboard.instantiateViewControllerWithIdentifier("chooseSide") as! ChooseSideViewController
                self.window?.rootViewController = initialViewController
                self.window?.makeKeyAndVisible()
            }
        }
        return true
    }
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackground()
    }
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010{
            print("Push Notifications not supported by IOS sim")
        }else{
             print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PFPush.handlePush(userInfo)
        if application.applicationState == UIApplicationState.Inactive{
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        }else if application.applicationState == UIApplicationState.Active{
            newData = true
        }
    }
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

