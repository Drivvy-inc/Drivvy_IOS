//
//  AccountViewController.swift
//  car_Banner
//
//  Created by максим теодорович on 23.10.2019.
//  Copyright © 2019 максим теодорович. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class AccountViewController: UIViewController {
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userNumberLabel: UILabel!
    @IBOutlet weak var userMailLabel: UILabel!
    @IBOutlet weak var useCarLabel: UILabel!
    @IBOutlet weak var userKmLabel: UILabel!
    @IBOutlet weak var userBalanceLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMemberProfile()
    }
    
    @IBAction func addUserInfoButtonClicked(_ sender: Any) {
        
    }
    @IBAction func siggnOutButtonClicked(_ sender: Any) {
        displayMessageSignOut(userMessage: "Are you shure?")
    }
    
    
// MARK: - loadMemberProfile
    func loadMemberProfile()
    {
        let accessToken: String? = KeychainWrapper.standard.string(forKey: "accessToken")
        let userId: String?      = KeychainWrapper.standard.string(forKey: "userId")

        let myUrl                = URL(string: "http://a56346bb.ngrok.io/api/account/home")
        var request              = URLRequest(url: myUrl!)
        request.httpMethod       = "POST"
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.addValue("\(accessToken!)", forHTTPHeaderField: "auth-token")

        let postString = ["_id": userId!] as [ String: String ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: postString, options: [])
        }catch let error {
            print(error.localizedDescription)
            displayMessage(userMessage: error.localizedDescription)
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if error != nil{
                self.displayMessage(userMessage: "Could not successfully perfom this request. please try again tater")
                print("error=\(String(describing: error))")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary
                if let parseJSON = json{
    //                      self.displayMessage(userMessage: "succ")OrderListPageViewController

                            DispatchQueue.main.async
                            {
                                let name   = parseJSON["name"] as? String
                                let phone = parseJSON["phone"] as? String
                                let email = parseJSON["email"] as? String
                                let km   = parseJSON["km"] as? String
                                let car = parseJSON["car"] as? String
                                if name?.isEmpty != nil{
                                    self.userNameLabel.text   = name!
                                    self.userNumberLabel.text = phone!
                                    self.userMailLabel.text   = email!
                                    if km?.isEmpty != nil && car?.isEmpty != nil{
                                        self.useCarLabel.text      = car!
                                        self.userKmLabel.text      = km!
                                        self.userBalanceLabel.text = "0"
                                    } else {
                                        self.useCarLabel.isHidden      = true
                                        self.userKmLabel.isHidden      = true
                                        self.userBalanceLabel.isHidden = true
                                    }
                                }
                            }
                    } else {
                        self.displayMessage(userMessage: "Could not successfully perfom this request. please try again tater")
                    }
                
            } catch {
                
                self.displayMessage(userMessage: "Could not successfully perfom this request. please try again tater! Error: \(error)")
                print(error)
            }
        
        }
        task.resume()

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
    
    func displayMessageSignOut(userMessage: String) -> Void {
        DispatchQueue.main.async{
            let alertController = UIAlertController(
                title: "SignOut",
                message: userMessage,
                preferredStyle: .alert)
            
            let OKAction = UIAlertAction(
                title: "Yes",
                style: .default) { (action:UIAlertAction!) in
                    print ("Ok button prassed")
                        KeychainWrapper.standard.removeObject(forKey: "accessToken")
                        KeychainWrapper.standard.removeObject(forKey: "userId")
                        
                        DispatchQueue.main.async
                        {
                        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = mainStoryboard.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
                        UIApplication.shared.keyWindow?.rootViewController = vc
                        }
                        self.dismiss(animated: true, completion: nil)
            }
            let CancelAction = UIAlertAction(
                title: "Cancel",
                style: .cancel) { (action:UIAlertAction!) in
                    print ("Ok button prassed")
                    DispatchQueue.main.async{
                        self.dismiss(animated: true, completion: nil)
                    }
            }
            
            alertController.addAction(OKAction)
            alertController.addAction(CancelAction)
            self.present(alertController, animated: true, completion: nil)
            
        }
    }
}
