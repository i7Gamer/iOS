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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Purchase History"
        
        // get app delegate
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        // get managed context
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // request
        let fetchRequest = NSFetchRequest<Purchase>(entityName: "Purchase")
        // load data
        do {
            purchases = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
