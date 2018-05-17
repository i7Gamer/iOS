//
//  AddShopViewController.swift
//  ShoppingList
//
//  Created by Timo Rzipa on 29.03.18.
//  Copyright © 2018 Timo Rzipa. All rights reserved.
//

import UIKit
import CoreData

class AddShopViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var cancelBtn: UIBarButtonItem!
    @IBOutlet weak var shopName: UITextField!
    @IBOutlet weak var shopAddress: UITextField!
    @IBOutlet weak var saveBtn: UIBarButtonItem!
    
    var shops: [Shop] = []
    var shopController:ShopTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.shopName.becomeFirstResponder()
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Shop>(entityName: "Shop")
        do {
            shops = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }

        shopName.delegate = self
        shopAddress.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if (textField === self.shopName) {
            for savedShop in shops {
                if (shopName.text == savedShop.name) {
                    alertWithUsage()
                    return false
                }
            }
        }
        return true
    }
    
    func alertWithUsage() {
        let alert = UIAlertController(title: "Information", message: "This Shop already exists!", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel,handler: {_ in });
        alert.addAction(action)
        self.present(alert, animated: true, completion:nil)
    }
    
    @IBAction func saveShopClicked(_ sender: Any) {
        var exists = false
        for savedShop in shops {
            if (shopName.text == savedShop.name) {
                exists = true
            }
        }
        if !exists {
            self.shopController?.saveShop(name: shopName.text!, address: shopAddress.text!)
        }
        self.dismiss(animated: true, completion: nil)
    }
}
