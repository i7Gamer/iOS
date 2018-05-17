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
    var boughtItems: [Item] = []
    
    public var shopId : Int16 = 0
    public var shopName : String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.largeTitleDisplayMode = UINavigationItem.LargeTitleDisplayMode.never;
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addProduct(sender:)))
        title = "Products for " + shopName
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Item>(entityName: "Item")
        fetchRequest.predicate = NSPredicate(format: "shopId == %@ && purchaseId == 0", String.init(shopId))
        do {
            items = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return items.count;
        }
        if(boughtItems.count > 0){
            return 1
        }
        else {
            return 0
        }
    }
    
    @objc func addProduct(sender: Any?) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let destination = storyboard.instantiateViewController(withIdentifier: "AddProductViewController") as! UINavigationController
        if let vc = destination.viewControllers.first as? AddProductViewController {
            vc.shopName = self.shopName
        }
        self.present(destination, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
        let item = items[indexPath.row]
            
        let cell = tableView.dequeueReusableCell(withIdentifier: "productTableViewCell", for: indexPath)
        
        let name = item.value(forKeyPath: "name") as! String
        let desc = item.value(forKeyPath: "desc") as! String
        var dateString = ""
        var amountString = ""
        
        if let amount = item.value(forKeyPath: "amount") as? String {
            if amount.count > 0 {
                amountString = amount + " "
            }
        }
        
        if let date = item.value(forKeyPath: "dueDate") as? Date {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            formatter.timeStyle = .none
            dateString = formatter.string(from: date)
            
            cell.textLabel?.text = amountString + name
            cell.detailTextLabel?.text = "Fällig bis: " + dateString + " | " + desc
        }
        else{
            cell.textLabel?.text = amountString + name
            cell.detailTextLabel?.text = desc
        }
            
        if(boughtItems.contains(item)){
            cell.accessoryType = UITableViewCellAccessoryType.checkmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.none;
        }
        
        return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "finishPurchaseButtonCell", for: indexPath)
            cell.textLabel?.text = "Finish Purchase"
            return cell;
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 0){
            tableView.deselectRow(at: indexPath, animated: true)
            self.buyItem(indexPath: indexPath)
        }
        else{
            if(boughtItems.count > 0){
                tableView.deselectRow(at: indexPath, animated: true)
                
                let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                let destination = storyboard.instantiateViewController(withIdentifier: "FinishPurchaseViewController") as! UINavigationController
                
                self.present(destination, animated: true, completion: nil)
            }
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath : IndexPath) -> [UITableViewRowAction]? {
        let item = items[indexPath.row]
        if(!boughtItems.contains(item)){
            
            let bought = UITableViewRowAction(style: .normal, title: "Bought") { action, index in
                self.buyItem(indexPath: indexPath)
            }
            bought.backgroundColor = .green
            
            let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
                self.editItem(indexPath: indexPath)
            }
            edit.backgroundColor = .orange
            
            let delete = UITableViewRowAction(style: .destructive, title: "Delete") { action, index in
                self.deleteItem(indexPath: indexPath)
            }
            delete.backgroundColor = .red
            
            return [delete, edit ,bought]
        }
        else{
            return []
        }
    }
    
    func deleteItem(indexPath : IndexPath){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let item = items[indexPath.row]
        managedContext.delete(item);
        items.remove(at: indexPath.row)
        self.tableView.reloadData()
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadShops"), object: nil)
    }
    
    func buyItem(indexPath : IndexPath){
        let item = items[indexPath.row]
        
        if isItemSelected(indexPath: indexPath) {
            removeItemFromBoughtItems(indexPath: indexPath)
        }else{
            boughtItems.append(item)
        }
        self.tableView.reloadData()
    }
    
    func removeItemFromBoughtItems(indexPath : IndexPath){
        let item = items[indexPath.row]
        if let index = boughtItems.index(of: item){
            boughtItems.remove(at: index)
        }
    }
    
    func isItemSelected(indexPath : IndexPath)-> Bool{
        let item = items[indexPath.row]
        return boughtItems.contains(item)
    }
    
    func editItem(indexPath : IndexPath){
    }
    
    @IBAction func finishPurchase(_ segue:UIStoryboardSegue){
        if let svc = segue.source as? FinishPurchaseViewController {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedContext = appDelegate.persistentContainer.viewContext
            
            var purchases: [Purchase] = []
            let fetchRequest = NSFetchRequest<Purchase>(entityName: "Purchase")
            
            do {
                purchases = try managedContext.fetch(fetchRequest)
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
            var max : Int16 = 0;
            for p in purchases{
                if(p.id > max){
                    max = p.id
                }
            }
            max = max + 1
            
            let purchase = NSEntityDescription.insertNewObject(forEntityName: "Purchase", into: managedContext) as! Purchase
            purchase.id = max
            let total = svc.total.text!.replacingOccurrences(of: ",", with: ".")
            purchase.total = Double(total)!
            purchase.date = Date.init()
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            
            for i in boughtItems {
                i.purchaseId = max;
                i.setValue(max, forKey: "purchaseId")
                do {
                    try managedContext.save()
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
                items = items.filter { $0 != i}
            }
            
            boughtItems = []
            self.tableView.reloadData()
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadPurchases"), object: nil)
        }
    }
    
    @IBAction func cancelPurchase(_ segue:UIStoryboardSegue){
    }
    
    @IBAction func saveProduct(_ segue:UIStoryboardSegue){
        if let svc = segue.source as? AddProductViewController {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedContext = appDelegate.persistentContainer.viewContext
            
            var allItems: [Item] = []
            let fetchRequest = NSFetchRequest<Item>(entityName: "Item")
            
            // load data
            do {
                allItems = try managedContext.fetch(fetchRequest)
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
            var max : Int16 = 0;
            
            for item in allItems{
                if(item.id > max){
                    max = item.id
                }
            }
            max = max + 1
            
            let index = svc.productShopPicker.selectedRow(inComponent: 0)
            let shop = svc.shops[index]
            
            let item = NSEntityDescription.insertNewObject(forEntityName: "Item", into: managedContext) as! Item
            item.id = max;
            item.shopId = shop.id
            item.name = svc.productName.text
            item.amount = svc.productAmount.text
            item.desc = svc.productDescription.text
            item.dueDate = svc.productDatePicker.date
            
            do {
                try managedContext.save()
                items.append(item)
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            
            self.tableView.reloadData()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadShops"), object: nil)
        }
    }
    
    @IBAction func cancelAddProduct(_ segue:UIStoryboardSegue){
    }
}
