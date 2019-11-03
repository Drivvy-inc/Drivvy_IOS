//
//  SignInViewController.swift
//  car_Banner
//
//  Created by максим теодорович on 10/18/19.
//  Copyright © 2019 максим теодорович. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class SignInViewController: UIViewController {
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func signInButtonClicked(_ sender: Any) {
        print("signin Button")

        let userName     = userNameTextField.text
        let userPassword = userPasswordTextField.text

        if (userName?.isEmpty)! || (userPassword?.isEmpty)!  {
            print("User name \(String(describing: userName)) or password \(String(describing: userPassword)) is empty")
            displayMessage(userMessage: "One of the required fields is missing!")

            return
        }
        
        let myActivityIndicator              = UIActivityIndicatorView( style: UIActivityIndicatorView.Style.medium )
        myActivityIndicator.center           = view.center
        myActivityIndicator.hidesWhenStopped = false
          myActivityIndicator.startAnimating()
          view.addSubview(myActivityIndicator)
        
        let myUrl = URL(string: "http://6445cf2c.ngrok.io/api/user/loginDriver")
        var request = URLRequest(url: myUrl!)
           request.httpMethod = "POST"
           request.addValue("application/json", forHTTPHeaderField: "content-type")
           request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let postString = ["email": userName!,
                         "password": userPassword!] as [ String: String ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: postString, options: [])
        }catch let error {
            print(error.localizedDescription)
            displayMessage(userMessage: error.localizedDescription)
            return
        }
        // MARK: - Post Request
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?)
            in
            
            self.removeActivityyIndicator(activityIndicator: myActivityIndicator)
            
            if error != nil{
                self.displayMessage(userMessage: "Could not successfully perfom this request. please try again tater")
                print("error=\(String(describing: error))")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
               if httpResponse.statusCode == 401 {
                   print("error \(httpResponse.statusCode)")
                   self.displayMessage(userMessage: "Email or Password inccorect!")
                   return
               } else if httpResponse.statusCode == 400 {
                  print("error \(httpResponse.statusCode)")
                  self.displayMessage(userMessage: "Something wrong! Please check all fields, and try again later )")
                  return
              }
           }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary
                
                if let parseJSON = json{
                    
                    let userId      = parseJSON["_id"] as? String
                    let accessToken = parseJSON["token"] as? String
                    print("UserId=\(String(describing: userId))")
                    print("Access Token=\(String(describing: accessToken!))")
                    
                    let saveAccessToken: Bool = KeychainWrapper.standard.set(accessToken!, forKey: "accessToken")
                    let saveUserId: Bool = KeychainWrapper.standard.set(userId!, forKey: "userId")
                    
                    print("saveAccessToken: \(saveAccessToken)")
                    print("saveUserId: \(saveUserId)")

                    if (accessToken?.isEmpty)!
                    {
                        self.displayMessage(userMessage: "Could not successfully perfom this request. please try again tater")
                        return
                    }
//                      self.displayMessage(userMessage: "succ")OrderListPageViewController

                        DispatchQueue.main.async
                        {
                            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                            let vc = mainStoryboard.instantiateViewController(withIdentifier: "MainTabBarViewController") as! MainTabBarViewController
                            UIApplication.shared.keyWindow?.rootViewController = vc
                        }
                } else {
                    self.displayMessage(userMessage: "Could not successfully perfom this request. please try again tater")
                }
            } catch {
            self.removeActivityyIndicator(activityIndicator: myActivityIndicator)
            
            self.displayMessage(userMessage: "Could not successfully perfom this request. please try again tater! Error: \(error)")
            print(error)
            }
        }
        task.resume()
    }
    // MARK: - registerButtonClicked

    @IBAction func registerButtonClicked(_ sender: Any) {
        print("Register Button")

        let RegisterUserViewController = self.storyboard?.instantiateViewController(withIdentifier: "RegisterUserViewController") as!  RegisterUserViewController

        self.present(RegisterUserViewController,animated: true)
    }

    func removeActivityyIndicator(activityIndicator: UIActivityIndicatorView){
        DispatchQueue.main.async{
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
        }
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
}
