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
        
        //self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTemplateItem(sender:)))
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
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
}
