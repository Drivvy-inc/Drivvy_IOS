//
//  SignInViewController.swift
//  car_Banner
//
//  Created by максим теодорович on 10/18/19.
//  Copyright © 2019 максим теодорович. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func signInButtonClicked(_ sender: Any) {
        print("signin Button")
        
        let userName = userNameTextField.text
        let userPassword = userPasswordTextField.text
        
        if (userName?.isEmpty)! || (userPassword?.isEmpty)!  {
            print("User name \(String(describing: userName)) or password \(String(describing: userPassword)) is empty")
            displayMessage(userMessage: "One of the required fields is missing!")
            
            return
        }
        
        let myActivityIndicator = UIActivityIndicatorView( style: UIActivityIndicatorView.Style.medium )
          myActivityIndicator.center = view.center
          myActivityIndicator.hidesWhenStopped = false
          myActivityIndicator.startAnimating()
          view.addSubview(myActivityIndicator)
        
        let myUrl = URL(string: "http://localhost:8000/api/user/loginDriver")
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
        
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?)
            in
            
            self.removeActivityyIndicator(activityIndicator: myActivityIndicator)
            
            if error != nil{
                self.displayMessage(userMessage: "Could not successfully perfom this request. please try again tater")
                print("error=\(String(describing: error))")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary
                
                if let parseJSON = json{
                    
                    let userId = parseJSON["_id"] as? String
                    let accessToken = parseJSON["token"] as? String
                    print("UserId=\(String(describing: userId))")
                    print("Access Token=\(String(describing: accessToken!))")

                    if (accessToken?.isEmpty)!
                    {
                        self.displayMessage(userMessage: "Could not successfully perfom this request. please try again tater")
                        return
                    }
//                      self.displayMessage(userMessage: "succ")

                        DispatchQueue.main.async
                        {
                            let orderListPage = self.storyboard?.instantiateViewController(withIdentifier: "OrderListPageViewController") as! OrderListPageViewController
                            let appDelegate = UIApplication.shared.delegate
                            appDelegate?.window??.rootViewController = orderListPage
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
