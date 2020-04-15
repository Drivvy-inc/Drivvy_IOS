//
//  displayMessage.swift
//  car_Banner
//
//  Created by максим теодорович on 15.12.2019.
//  Copyright © 2019 максим теодорович. All rights reserved.
//

import UIKit

class DisplayMessage {
    static let shered = DisplayMessage()
    
    func displayMessage(userMessage: String) -> (UIAlertController) {
            let alertController = UIAlertController(
                title: "Alert",
                message: userMessage,
                preferredStyle: .alert)
            
            let OKAction = UIAlertAction(
                title: "OK",
                style: .default) { (action:UIAlertAction!) in
                    print ("Ok button prassed")
            }
            
            alertController.addAction(OKAction)
            return alertController

    }
    private init(){}
}
//DispatchQueue.main.async{
//    self.present(DisplayMessage.shered.displayMessage(userMessage: "could not succsessful"), animated: true, completion: nil)
//    self.dismiss(animated: true, completion: nil)
//    }
//}


