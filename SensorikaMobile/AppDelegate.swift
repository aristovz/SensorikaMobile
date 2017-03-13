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
    let welcomeStoryBoard = UIStoryboard(name: "WelcomeStoryboard", bundle: nil)
    
    let freqs = [[0, 0, 0, 0, 0, -1, -2],
                 [0, 0, -1, -1, 0, 0, -1],
                 [0, 0, -1, -1, 0, -2, -2],
                 [0, 1, 0, 0, 0, -1, 0]]
    let names = ["Clean room", "Стандарт", "Детская", "Салон авто", "ПВХ"]
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        print(Realm.Configuration.defaultConfiguration.fileURL!.absoluteString)
        UIApplication.shared.statusBarStyle = .lightContent
        
        if UserDefaults.standard.bool(forKey: "didShowTutorial") {
            loadMainStoryboard()
        }
        else {
            loadTutorialStoryBoard()
        }
        
        
        return true
    }
    
    func loadTutorialStoryBoard() {
        let storyboard = UIStoryboard(name: "WelcomeStoryboard", bundle: nil)
        if let controller = storyboard.instantiateInitialViewController() {
            self.window?.rootViewController = controller
        }
    }
    
    func loadMainStoryboard() {
        Global.SENSORS.LoadSensor()
        loadStartData()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let controller = storyboard.instantiateInitialViewController() {
            self.window?.rootViewController = controller
        }
    }
    
    func loadStartData() {
        let measures = Array(uiRealm.objects(MeasureObject.self))
        
        if measures.count == 0 {
            try! uiRealm.write {
                for k in 0..<names.count {
                    let measure = MeasureObject(value:["id" : MeasureObject.incrementID!, "name": names[k], "groupId" : -4, "mask" : Global.standartMask])
                    
                    for k in 0..<Global.SENSORS.sensors.count {
                        let startFreqData = FreqDataObject()
                        startFreqData.id = FreqDataObject.incrementID!
                        startFreqData.measure = measure
                        startFreqData.freqValue = 0
                        startFreqData.timeValue = -1
                        startFreqData.sensorId = Global.SENSORS[k]!.ID
                        
                        measure.freqData.append(startFreqData)
                        uiRealm.add(startFreqData)
                        
                        var index = 0
                        for s in 0..<61 {
                            if s <= 4 {
                                index = 0
                            }
                            else if s <= 6 {
                                index = 1
                            }
                            else if s <= 8 {
                                index = 2
                            }
                            else if s <= 10 {
                                index = 3
                            }
                            else if s <= 20 {
                                index = 4
                            }
                            else if s <= 40 {
                                index = 5
                            }
                            else {
                                index = 6
                            }
                            
                            let freqData = FreqDataObject()
                            freqData.id = FreqDataObject.incrementID!
                            freqData.measure = measure
                            freqData.freqValue = Double(freqs[k][index])
                            freqData.timeValue = Double(s)
                            freqData.sensorId = Global.SENSORS[k]!.ID
                            
                            measure.freqData.append(freqData)
                            uiRealm.add(freqData)
                        }
                    }
                    uiRealm.add(measure)
                }
                
                let groups = [Group(value:["id" : Group.negativeIncrementID, "name": "Дом"]),
                              Group(value:["id" : Group.negativeIncrementID - 1, "name": "Офис"]),
                              Group(value:["id" : Group.negativeIncrementID - 2, "name": "Ресторан"]),
                              Group(value:["id" : Group.negativeIncrementID - 3, "name": "Полимер"])]
                
                uiRealm.add(groups)
            }
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

