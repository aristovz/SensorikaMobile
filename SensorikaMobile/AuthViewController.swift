
//
//  AuthViewController.swift
//  SensorikaMobile
//
//  Created by Pavel Aristov on 13.03.17.
//  Copyright © 2017 aristovz. All rights reserved.
//

import UIKit

class AuthViewController: UIViewController {

    @IBOutlet weak var loginTextFied: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButtonOutlet: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loginButtonOutlet.layer.cornerRadius = 20
        loginButtonOutlet.layer.borderWidth = 1
        loginButtonOutlet.layer.borderColor = UIColor.buttonBorder.cgColor
    }
    
    @IBAction func loginButtonAction(_ sender: UIButton) {
        UserDefaults.standard.set(true, forKey: "didShowTutorial")
        Global.appDelegate.loadMainStoryboard()
    }
}
