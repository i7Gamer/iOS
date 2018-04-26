//
//  ProductTableViewController.swift
//  ShoppingList
//
//  Created by Timo Rzipa on 05.04.18.
//  Copyright © 2018 Timo Rzipa. All rights reserved.
//

import UIKit
import CoreData

class ProductTableViewController: UITableViewController {

    var items: [Item] = []
    
    public var shopId : Int16 = 0
    public var shopName : String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.largeTitleDisplayMode = UINavigationItem.LargeTitleDisplayMode.never;
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addProduct(sender:)))
        title = "Products for " + shopName
        
        // get app delegate
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        // get managed context
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // request
        let fetchRequest = NSFetchRequest<Item>(entityName: "Item")
        fetchRequest.predicate = NSPredicate(format: "shopId == %@", String.init(shopId))
        
        // load data
        do {
            items = try managedContext.fetch(fetchRequest)
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
        return items.count;
    }
    
    @objc func addProduct(sender: Any?) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let destination = storyboard.instantiateViewController(withIdentifier: "AddProductViewController") as! UINavigationController
        
        self.present(destination, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "productTableViewCell", for: indexPath)
        cell.textLabel?.text = item.value(forKeyPath: "name") as? String
        cell.detailTextLabel?.text = item.value(forKeyPath: "amount") as? String
        return cell
    }
    
    @IBAction func saveProduct(_ segue:UIStoryboardSegue){
        //if let nav = segue.source as? UINavigationController {
            if let svc = segue.source as? AddProductViewController {
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
                let managedContext = appDelegate.persistentContainer.viewContext
                
                var max : Int16 = 0;
                
                for item in items{
                    if(item.id > max){
                        max = item.id
                    }
                }
                max = max + 1
                
                let item = NSEntityDescription.insertNewObject(forEntityName: "Item", into: managedContext) as! Item
                item.id = max;
                item.name = svc.productName.text
                item.shopId = shopId;
                item.amount = svc.productAmount.text
                item.desc = svc.productDescription.text
//                item.shop = svc.productShopPicker.
//                item.dueDate = svc.productDatePicker.date
                
                do {
                    try managedContext.save()
                    items.append(item)
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
                
                self.tableView.reloadData()
            }
        //}
    }
    
    @IBAction func cancelAddProduct(_ segue:UIStoryboardSegue){
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedContext = appDelegate.persistentContainer.viewContext
            let item = items[indexPath.row]
            managedContext.delete(item);
            items.remove(at: indexPath.row)
            self.tableView.reloadData()
        }
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
