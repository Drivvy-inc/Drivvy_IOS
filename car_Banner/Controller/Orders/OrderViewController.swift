//
//  OrderViewController.swift
//  car_Banner
//
//  Created by максим теодорович on 04.11.2019.
//  Copyright © 2019 максим теодорович. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class OrderViewController: UIViewController {
    @IBOutlet weak var orderImage: UIImageView!
    @IBOutlet weak var orderNameCompany: UILabel!
    
    var image = UIImage()
    var orderCompanyNameParse = ""
    var orderCompanyIdParse = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        orderImage.image = image
        orderNameCompany.text! = orderCompanyNameParse
        orderImage.layer.cornerRadius = 4.0
        orderImage.layer.borderWidth = 1.0
        orderImage.layer.borderColor = UIColor.clear.cgColor
        orderImage.layer.masksToBounds = false
        orderImage.layer.shadowColor = UIColor.gray.cgColor
        orderImage.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        orderImage.layer.shadowRadius = 4.0
        orderImage.layer.shadowOpacity = 1.0
        orderImage.layer.masksToBounds = false
        

        // Do any additional setup after loading the view.
    }
    // MARK: - cancelOrderButton
    @IBAction func cancelOrderButton(_ sender: Any) {
        DispatchQueue.main.async{
           self.dismiss(animated: true, completion: nil)
       }
    }
    // MARK: - confirmOrderButton
    @IBAction func confirmOrderButton(_ sender: Any) {
        displayMessage(userMessage: orderCompanyNameParse, companyId: orderCompanyIdParse)
    }
    
    func displayMessage(userMessage: String, companyId: Any) -> Void {
        DispatchQueue.main.async{
            let alertController = UIAlertController(
                title: "Alert",
                message: "You are sure that you want to confirm the order from: " + userMessage,
                preferredStyle: .alert)
            
            let OKAction = UIAlertAction(
                title: "OK",
                style: .default) { (action:UIAlertAction!) in
                    print ("Ok button prassed")
                    DispatchQueue.main.async{
                        self.confirmOrder(companyName: userMessage, companyId: companyId)
                        self.dismiss(animated: true, completion: nil)
                    }
            }
            let CancelAction = UIAlertAction(
               title: "Cancel",
               style: .cancel) { (action:UIAlertAction!) in
                   print ("Cancel button prassed")
                   DispatchQueue.main.async{
                       self.dismiss(animated: true, completion: nil)
                   }
            }
             
            alertController.addAction(CancelAction)

            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion: nil)
            
        }
    }
    
    func displayMessageAlart(userMessage: String) -> Void {
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
    // MARK: - Put request to Confirm!

    func confirmOrder(companyName: String, companyId: Any){
        let accessToken: String? = KeychainWrapper.standard.string(forKey: "accessToken")
        let endpoint = Settings.shered.endpoint

        let myUrl = URL(string: endpoint + "api/order/confirmOrder")

        var request              = URLRequest(url: myUrl!)
        request.httpMethod       = "POST"
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.addValue("\(accessToken!)", forHTTPHeaderField: "auth-token")
        
        let postString = [
            "status": "inProcess",
            "companyName": companyName,
            "companyId": companyId] as! [ String: String ]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: postString, options: [])
        }catch let error {
            print(error.localizedDescription)
            displayMessageAlart(userMessage: error.localizedDescription)
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
                
                if error != nil{
                    self.displayMessageAlart(userMessage: "Could not successfully perfom this request. please try again tater")
                    print("error=\(String(describing: error))")
                    return
                }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary
                    if let parseJSON = json{
                            DispatchQueue.main.async
                            {
                                let status        = parseJSON["status"] as? String
                                let companyName   = parseJSON["companyName"] as? String
                                print(status, companyName)
                            }
                        } else {
                            self.displayMessageAlart(userMessage: "Could not successfully perfom this request. please try again tater")
                        }
                    
                } catch {
                    self.displayMessageAlart(userMessage: "Could not successfully perfom this request. please try again tater! Error: \(error)")
                    print(error)
                }
            
            }
            task.resume()
    }
}
