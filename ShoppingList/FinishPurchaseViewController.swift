//
//  FinishPurchaseViewController.swift
//  ShoppingList
//
//  Created by Timo Rzipa on 03.05.18.
//  Copyright © 2018 Timo Rzipa. All rights reserved.
//

import UIKit

class FinishPurchaseViewController: UIViewController {

    @IBOutlet weak var total: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.total.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
