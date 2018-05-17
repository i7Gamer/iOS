//
//  AddProductViewController.swift
//  ShoppingList
//
//  Created by Timo Rzipa on 05.04.18.
//  Copyright © 2018 Timo Rzipa. All rights reserved.
//

import UIKit
import CoreData

class AddProductViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource  {
    
    @IBOutlet weak var productName: UITextField!
    @IBOutlet weak var productAmount: UITextField!
    @IBOutlet weak var productDescription: UITextField!
    @IBOutlet weak var productShopPicker: UIPickerView!
    @IBOutlet weak var productDatePicker: UIDatePicker!
    
    var shops: [Shop] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.productName.becomeFirstResponder()
        
        // get app delegate
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        // get managed context
        let managedContext = appDelegate.persistentContainer.viewContext
        // request
        let fetchRequest = NSFetchRequest<Shop>(entityName: "Shop")
        // load data
        do {
            shops = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        self.productShopPicker.delegate = self as UIPickerViewDelegate
        self.productShopPicker.dataSource = self as UIPickerViewDataSource
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return shops.count;
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return shops[row].name
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
