//
//  AppDelegate.swift
//  ShoppingList
//
//  Created by Timo Rzipa on 29.03.18.
//  Copyright © 2018 Timo Rzipa. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // get app delegate
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return true}
        let managedContext = appDelegate.persistentContainer.viewContext
        
        do {
            // get all purchases
            let fetchRequestPurchases = NSFetchRequest<Purchase>(entityName: "Purchase")
            var purchases: [Purchase] = []
            purchases = try managedContext.fetch(fetchRequestPurchases)
            
            var items: [Item] = []
            let fetchRequestAllItems = NSFetchRequest<Item>(entityName: "Item")
            items = try managedContext.fetch(fetchRequestAllItems)
            
            var templateItems: [TemplateItem] = []
            let fetchRequestAllTemplateItems = NSFetchRequest<TemplateItem>(entityName: "TemplateItem")
            templateItems = try managedContext.fetch(fetchRequestAllTemplateItems)
            
            // get all shops
            let fetchRequestAll = NSFetchRequest<Shop>(entityName: "Shop")
            var shops = try managedContext.fetch(fetchRequestAll)
            
            // get no shop
            let fetchRequest = NSFetchRequest<Shop>(entityName: "Shop")
            fetchRequest.predicate = NSPredicate(format: "name == %@", "No shop")
            
            let shop = try managedContext.fetch(fetchRequest)
            
            if(shop.count == 0){
                // save shop
                
                var max : Int16 = 0;
                for shop in shops{
                    if(shop.id > max){
                        max = shop.id
                    }
                }
                max = max + 1
                
                let shop = NSEntityDescription.insertNewObject(forEntityName: "Shop", into: managedContext) as! Shop
                shop.name = "No shop";
                shop.id = max;
                do {
                    try managedContext.save()
                    shops.append(shop)
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
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
        let container = NSPersistentContainer(name: "ShoppingListDataModel")
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
