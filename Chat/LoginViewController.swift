//
//  LoginViewController.swift
//  Chat
//
//  Created by Patrick Ridd on 8/10/16.
//  Copyright © 2016 PatrickRidd. All rights reserved.
//

import UIKit

protocol LoginDelegate: class {
    
  func presentPressButtonAction()

}

class LoginViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func chanceChatButtonTapped(sender: AnyObject) {
        guard let username = textField.text where !(username.isEmpty) else {
            presentAlert()
            return
        }
        
        UserController.sharedController.createUser(username)
        dismissViewControllerAnimated(true, completion: nil)

        
    }

    func presentAlert() {
        let alert = UIAlertController(title: "Incorrect Username Input", message: "Username needs at least one character", preferredStyle: .Alert)
        let action = UIAlertAction(title: "Got it", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)

        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
