//
//  AppDelegate.swift
//  SensorikaMobile
//
//  Created by Pavel Aristov on 26.01.17.
//  Copyright © 2017 NetSharks. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift

let uiRealm = try! Realm()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        print(Realm.Configuration.defaultConfiguration.fileURL!.absoluteString)
        UIApplication.shared.statusBarStyle = .lightContent
        
        let measures = Array(uiRealm.objects(MeasureObject.self))
        
        if measures.count == 0 {
            let measures1 = [MeasureObject(value:["id" : MeasureObject.incrementID!, "name": "M - 1.1", "groupId" : -1, "mask" : "5 15 20 25 30 35 40 45 50 55 60"]),
                             MeasureObject(value:["id" : MeasureObject.incrementID! + 1, "name": "M - 1", "mask" : "5 15 20 25 30"]),
                             MeasureObject(value:["id" : MeasureObject.incrementID! + 2, "name": "M - 1.1.1", "groupId" : -3, "mask" : "1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20"])]
            
            let groups = [Group(value:["id" : Group.negativeIncrementID, "name": "G - 1"]),
                          Group(value:["id" : Group.negativeIncrementID - 1, "name": "G - 1.1", "groupId" : -1]),
                          Group(value:["id" : Group.negativeIncrementID - 2, "name": "G - 2"])]
            
            try! uiRealm.write {
                uiRealm.add(measures1)
                uiRealm.add(groups)
            }
        }
        
        Global.SENSORS.LoadSensor()
        
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
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "SensorikaMobile")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

