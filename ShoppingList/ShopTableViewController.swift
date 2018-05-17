//
//  TableViewController.swift
//  ShoppingList
//
//  Created by Timo Rzipa on 29.03.18.
//  Copyright © 2018 Timo Rzipa. All rights reserved.
//

import UIKit
import CoreData

class ShopTableViewController: UITableViewController {
    var shops: [Shop] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadList), name: NSNotification.Name(rawValue: "reloadShops"), object: nil)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Shop>(entityName: "Shop")
        fetchRequest.predicate = NSPredicate(format: "hasBeenDeleted == false")
        do {
            shops = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    @objc func reloadList(){
        //load data here
        self.tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let destination = storyboard.instantiateViewController(withIdentifier: "ItemViewController") as! ProductTableViewController
        let shop = shops[indexPath.row];
        
        destination.shopId = (shop.value(forKeyPath: "id") as? Int16)!
        destination.shopName = (shop.value(forKeyPath: "name") as? String)!
        
        navigationController?.pushViewController(destination, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shops.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let shop = shops[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableviewcell", for: indexPath)
        
        var items: [Item] = []
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return cell}
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Item>(entityName: "Item")
        fetchRequest.predicate = NSPredicate(format: "shopId == %@ && purchaseId == 0", String(shop.id))
        do {
            items = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        let name = shop.value(forKeyPath: "name") as? String?
        
        cell.textLabel?.text = name!! + " (" + String(items.count) + ")"
        cell.detailTextLabel?.text = shop.value(forKeyPath: "address") as? String
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedContext = appDelegate.persistentContainer.viewContext
            
            let shop = shops[indexPath.row]
            shop.hasBeenDeleted = true;
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            self.tableView.reloadData()
        }
    }
    
    func saveShop(name:String, address:String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        var max : Int16 = 0;
        
        for shop in shops{
            if(shop.id > max){
                max = shop.id
            }
        }
        max = max + 1
        
        let shop = NSEntityDescription.insertNewObject(forEntityName: "Shop", into: managedContext) as! Shop
        shop.name = name
        shop.address = address
        shop.id = max;
        do {
            try managedContext.save()
            shops.append(shop)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        self.tableView.reloadData()
    }
    
    @IBAction func cancelAddShop(_ segue:UIStoryboardSegue){
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nc = segue.destination as? UINavigationController {
            if let vc = nc.viewControllers.first as? AddShopViewController {
                vc.shopController = self
            }
        }
    }
}
