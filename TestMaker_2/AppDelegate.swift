//
//  AppDelegate.swift
//  TestMaker_2
//
//  Created by 山田敬汰 on 2016/12/25.
//  Copyright © 2016年 YamadaKeita. All rights reserved.
//

import UIKit
import StoreKit
import Firebase
import FirebaseAuth
import FirebaseDynamicLinks
import FirebaseUI
import Foundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, PurchaseManagerDelegate {

    var window: UIWindow?
    
    var viewController: MainViewController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "7c33e3926b9326dc700d3056285f5e85", (kGADSimulatorID as! String)]
        // デリゲート設定
        PurchaseManager.sharedManager().delegate = self
        // オブザーバー登録
        SKPaymentQueue.default().add(PurchaseManager.sharedManager())

        return true
    }
    
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        guard
            userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let webpageURL = userActivity.webpageURL else {
                return false
        }
        return DynamicLinks.dynamicLinks().handleUniversalLink(webpageURL) { dynamiclink, error in
            guard let url = dynamiclink!.url else { return }
            
            // ディープリンク URLを使用する処理...
                    
            self.viewController?.downloadFromUrl(url)
            
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

        SKPaymentQueue.default().remove(PurchaseManager.sharedManager())

    }

    // 課金終了(前回アプリ起動時課金処理が中断されていた場合呼ばれる)
    func purchaseManager(_ purchaseManager: PurchaseManager!, didFinishUntreatedPurchaseWithTransaction transaction: SKPaymentTransaction!, decisionHandler: ((_ complete: Bool) -> Void)!) {
        print("#### didFinishUntreatedPurchaseWithTransaction ####")

        let ud = UserDefaults.standard
        ud.set(true, forKey: "RemoveAd")

        //コンテンツ解放が終了したら、この処理を実行(true: 課金処理全部完了, false 課金処理中断)
        decisionHandler(true)
    }
}
