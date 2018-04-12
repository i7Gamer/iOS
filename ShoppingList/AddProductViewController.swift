//
//  AddProductViewController.swift
//  ShoppingList
//
//  Created by Timo Rzipa on 05.04.18.
//  Copyright © 2018 Timo Rzipa. All rights reserved.
//

import UIKit

class AddProductViewController: UIViewController {

    @IBOutlet weak var productName: UITextField!
    @IBOutlet weak var productAmount: UITextField!
    @IBOutlet weak var productDescription: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
