//
//  TemplateTableViewController.swift
//  ShoppingList
//
//  Created by SCHATZMANN Julia on 26.04.18.
//  Copyright © 2018 Timo Rzipa. All rights reserved.
//

import UIKit
import CoreData

class TemplateTableViewController: UITableViewController {

    var templates: [Template] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Templates"
        
        // get app delegate
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        // get managed context
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // request
        let fetchRequest = NSFetchRequest<Template>(entityName: "Template")
        // load data
        do {
            templates = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let destination = storyboard.instantiateViewController(withIdentifier: "TemplateItemController") as! TemplateItemTableViewController
        let template = templates[indexPath.row];
        
        destination.templateId = (template.value(forKeyPath: "id") as? Int16)!
        destination.templateName = (template.value(forKeyPath: "name") as? String)!
        
        navigationController?.pushViewController(destination, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return templates.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let template = templates[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "templateCell", for: indexPath)
        cell.textLabel?.text = template.value(forKeyPath: "name") as? String
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath : IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { action, index in
            self.deleteItem(indexPath: indexPath)
        }
        delete.backgroundColor = .red
        
        let addToShoppingList = UITableViewRowAction(style: .destructive, title: "Add to Shopping list") { action, index in
            self.moveTemplateItemsToShop(indexPath: indexPath)
        }
        addToShoppingList.backgroundColor = .green
        
        return [delete, addToShoppingList]
    }
    
    func deleteItem(indexPath : IndexPath){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let template = templates[indexPath.row]
        managedContext.delete(template);
        templates.remove(at: indexPath.row)
        self.tableView.reloadData()
    }
    
    func moveTemplateItemsToShop(indexPath : IndexPath){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let template = templates[indexPath.row]
        
        // load data
        do {
            let fetchRequest = NSFetchRequest<TemplateItem>(entityName: "TemplateItem")
            fetchRequest.predicate = NSPredicate(format: "templateId == %@", String.init(template.id))
            
            let templateItems = try managedContext.fetch(fetchRequest)
            
            for templateItem in templateItems {
                moveTemplateItemToShop(templateItem)
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        self.tableView.reloadData()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadShops"), object: nil)
    }
    
    func moveTemplateItemToShop(_ templateItem : TemplateItem){
        //if let nav = segue.source as? UINavigationController {
        
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
        
        //check if shop does already exist
        // request
        let shopRequest = NSFetchRequest<Shop>(entityName: "Shop")
        shopRequest.predicate = NSPredicate(format: "hasBeenDeleted == false")
        var allAvailableShops: [Shop] = []
        // load data
        do {
            allAvailableShops = try managedContext.fetch(shopRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        var foundAvailableShop = false
        for shop in allAvailableShops{
            if(shop.id == templateItem.id){
                foundAvailableShop = true
            }
        }
        
        let item = NSEntityDescription.insertNewObject(forEntityName: "Item", into: managedContext) as! Item
        item.id = max;
        item.name = templateItem.name
        if foundAvailableShop{
            item.shopId = templateItem.shopId
        } else {
            item.shopId = 0 //this is always the default shop!
        }
        
        item.amount = templateItem.amount
        item.desc = templateItem.desc
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        self.tableView.reloadData()
    }
    
    @IBAction func saveTemplate(_ segue:UIStoryboardSegue){
        if let svc = segue.source as? AddTemplateViewController {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedContext = appDelegate.persistentContainer.viewContext
            
            var max : Int16 = 0;
            
            for template in templates{
                if(template.id > max){
                    max = template.id
                }
            }
            max = max + 1
            
            let template = NSEntityDescription.insertNewObject(forEntityName: "Template", into: managedContext) as! Template
            template.name = svc.templateName.text
            template.id = max;
            do {
                try managedContext.save()
                templates.append(template)
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            
            self.tableView.reloadData()
        }
    }
    
    @IBAction func cancelAddTemplate(_ segue:UIStoryboardSegue){
    }
}
