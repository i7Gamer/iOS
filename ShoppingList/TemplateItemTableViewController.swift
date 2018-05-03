//
//  TemplateItemTableViewController.swift
//  ShoppingList
//
//  Created by SCHATZMANN Julia on 26.04.18.
//  Copyright © 2018 Timo Rzipa. All rights reserved.
//

import UIKit
import CoreData

class TemplateItemTableViewController: UITableViewController {
    var templateItems: [TemplateItem] = []
    
    public var templateId : Int16 = 0
    public var templateName : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.largeTitleDisplayMode = UINavigationItem.LargeTitleDisplayMode.never;
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTemplateItem(sender:)))
        title = templateName
        
        // get app delegate
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        // get managed context
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // request
        let fetchRequest = NSFetchRequest<TemplateItem>(entityName: "TemplateItem")
        fetchRequest.predicate = NSPredicate(format: "templateId == %@", String.init(templateId))
        
        // load data
        do {
            templateItems = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return templateItems.count
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = templateItems[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "templateItemsTableViewCell", for: indexPath)
        
        let name = item.value(forKeyPath: "name") as! String
        let desc = item.value(forKeyPath: "desc") as! String
        
        var amountString = ""
        if let amount = item.value(forKeyPath: "amount") as? String {
            amountString = amount + " "
        }
        cell.textLabel?.text = amountString + name
        cell.detailTextLabel?.text = desc
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedContext = appDelegate.persistentContainer.viewContext
            let item = templateItems[indexPath.row]
            managedContext.delete(item);
            templateItems.remove(at: indexPath.row)
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath : IndexPath) -> [UITableViewRowAction]? {
            let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
                self.editItem(indexPath: indexPath)
            }
            edit.backgroundColor = .orange
            
            let delete = UITableViewRowAction(style: .destructive, title: "Delete") { action, index in
                self.deleteItem(indexPath: indexPath)
            }
            delete.backgroundColor = .red
            
            return [delete, edit]
    }
    
    func deleteItem(indexPath : IndexPath){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let item = templateItems[indexPath.row]
        managedContext.delete(item);
        templateItems.remove(at: indexPath.row)
        self.tableView.reloadData()
    }
    
    func editItem(indexPath : IndexPath){
        print("edit item tapped")
    }
    
    @objc func addTemplateItem(sender: Any?) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let destination = storyboard.instantiateViewController(withIdentifier: "AddTemplateItemController") as! UINavigationController
        
        self.present(destination, animated: true, completion: nil)
    }
    
    @IBAction func saveTemplateItem(_ segue:UIStoryboardSegue){
        if let svc = segue.source as? AddTemplateItemController {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedContext = appDelegate.persistentContainer.viewContext
            
            var max : Int16 = 0;
            
            for item in templateItems{
                if(item.id > max){
                    max = item.id
                }
            }
            max = max + 1
            
            let templateItem = NSEntityDescription.insertNewObject(forEntityName: "TemplateItem", into: managedContext) as! TemplateItem
            templateItem.id = max;
            templateItem.name = svc.templateItemName.text
            templateItem.desc = svc.templateItemDescription.text;
            templateItem.amount = svc.templateItemAmount.text;
            templateItem.templateId = templateId;
            
            do {
                try managedContext.save()
                templateItems.append(templateItem)
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            
            self.tableView.reloadData()
        }
    }
    
    @IBAction func cancelAddTemplateItem(_ segue:UIStoryboardSegue){
    }
}
