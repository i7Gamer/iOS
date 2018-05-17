//
//  AddShopViewController.swift
//  ShoppingList
//
//  Created by Timo Rzipa on 29.03.18.
//  Copyright © 2018 Timo Rzipa. All rights reserved.
//

import UIKit

class AddShopViewController: UIViewController {

    @IBOutlet weak var cancelBtn: UIBarButtonItem!
    @IBOutlet weak var shopName: UITextField!
    @IBOutlet weak var shopAddress: UITextField!
    @IBOutlet weak var saveBtn: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
