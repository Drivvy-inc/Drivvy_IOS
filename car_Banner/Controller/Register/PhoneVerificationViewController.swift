//
//  PhoneVerificationViewController.swift
//  car_Banner
//
//  Created by максим теодорович on 15.12.2019.
//  Copyright © 2019 максим теодорович. All rights reserved.
//

import UIKit

class PhoneVerificationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
   func displayMessage(userMessage: String) -> Void {
        DispatchQueue.main.async{
            let alertController = UIAlertController(
                title: "Alert",
                message: userMessage,
                preferredStyle: .alert)
            
            let OKAction = UIAlertAction(
                title: "OK",
                style: .default) { (action:UIAlertAction!) in
                    print ("Ok button prassed")
                    DispatchQueue.main.async{
                        self.dismiss(animated: true, completion: nil)
                    }
            }
            
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion: nil)
            
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
