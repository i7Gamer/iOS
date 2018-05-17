//
//  PurchaseHistoryTableViewController.swift
//  ShoppingList
//
//  Created by Timo Rzipa on 17.05.18.
//  Copyright © 2018 Timo Rzipa. All rights reserved.
//

import UIKit
import CoreData

class PurchaseHistoryTableViewController: UITableViewController {

    var purchases: [Purchase] = []
    
    @objc func reloadList(){
        //load data here
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadList), name: NSNotification.Name(rawValue: "reloadPurchases"), object: nil)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Purchase>(entityName: "Purchase")
        do {
            purchases = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return purchases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let purchase = purchases[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "PurchaseHistoryTableViewCell", for: indexPath)
        
        let optionalDate = purchase.value(forKeyPath: "date") as? Date?
        let total = purchase.value(forKeyPath: "total") as? Double
        let id = purchase.value(forKeyPath: "id") as? Int16
        
        var items: [Item] = []
        
        var shop: [Shop] = []
        
        // get app delegate
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return cell}
        // get managed context
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // request
        let fetchRequest = NSFetchRequest<Item>(entityName: "Item")
        fetchRequest.predicate = NSPredicate(format: "purchaseId == %@", String(id!))
        
        // load data for items
        do {
            items = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        if(items.count > 0)
        {
            // request
            let fetchRequest2 = NSFetchRequest<Shop>(entityName: "Shop")
            fetchRequest2.predicate = NSPredicate(format: "id == %@", String(items[0].shopId))
            
            // load data for items
            do {
                shop = try managedContext.fetch(fetchRequest2)
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            var dateString = ""
            
            if let date = optionalDate as? Date {
                let formatter = DateFormatter()
                formatter.dateStyle = .long
                formatter.timeStyle = .none
                dateString = formatter.string(from: date)
            }
            
            var productString = " product"
            
            if(items.count > 1){
                productString = " products"
            }
            
            if(shop.count > 0)
            {
                cell.textLabel?.text = dateString + " @ " + shop[0].name!;
                cell.detailTextLabel?.text = String(items.count) + productString + " for " + String(format:"%.0f", total!) + "€"
            }
        }
        return cell
    }
}
