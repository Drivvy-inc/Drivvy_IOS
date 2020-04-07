//
//  RegisterLabelViewController.swift
//  car_Banner
//
//  Created by Fire God on 31.03.2020.
//  Copyright © 2020 максим теодорович. All rights reserved.
//

import UIKit

class RegisterLabelViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var nameRegTextField: UITextField!
    @IBOutlet weak var phoneRegTextField: UITextField!
    @IBOutlet weak var emailRegTextField: UITextField!
    @IBOutlet weak var passwordRegTextField: UITextField!
    @IBOutlet weak var repPasswordRegTextField: UITextField!
    @IBOutlet weak var registerDesignButton: UIButton!
    @IBOutlet weak var termsStuffTextField: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Settings.shered.buttonsParametrs(obj: registerDesignButton, rad: 20)
        self.passwordRegTextField.addBottomBorder()
        self.repPasswordRegTextField.addBottomBorder()
        self.emailRegTextField.addBottomBorder()
        self.nameRegTextField.addBottomBorder()
        self.phoneRegTextField.addBottomBorder()
        self.phoneRegTextField.delegate = self
        self.emailRegTextField.delegate = self
        self.passwordRegTextField.delegate = self
        self.nameRegTextField.delegate = self
        self.repPasswordRegTextField.delegate = self

        // Do any additional setup after loading the view.
    }
    
    @IBAction func checkBoxTapped(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
        } else {
            sender.isSelected = true
        }
    }
    
    @IBAction func registerUserButtonClicked(_ sender: Any) {
        if (nameRegTextField.text?.isEmpty)! ||
        (phoneRegTextField.text?.isEmpty)! ||
        (emailRegTextField.text?.isEmpty)! ||
        (passwordRegTextField.text?.isEmpty)! {
            return displayMessage(userMessage: "All fields are quired to fill in!")
        }
        
        if ((repPasswordRegTextField.text?.elementsEqual(repPasswordRegTextField.text!))! != true) {
            return displayMessage(userMessage: "Please make sure that your passwords match")
        }
        
        let myActivityIndicator = UIActivityIndicatorView( style: UIActivityIndicatorView.Style.medium )
        myActivityIndicator.center = view.center
        myActivityIndicator.hidesWhenStopped = false
        myActivityIndicator.startAnimating()
        view.addSubview(myActivityIndicator)
        let endpoint = Settings.shered.endpoint

        let myUrl = URL(string: endpoint + "api/user/registerDriver")
        
        let parameters = ["name": nameRegTextField.text!,
                          "email": emailRegTextField.text!,
                          "phone": phoneRegTextField.text!,
                          "password": repPasswordRegTextField.text!] as [ String: String ]
        
        var request = URLRequest(url: myUrl!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch let error {
            print(error.localizedDescription)
            displayMessage(userMessage: error.localizedDescription)
            return
        }
                
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?)
            in
            
            self.removeActivityyIndicator(activityIndicator: myActivityIndicator)
            
            if error != nil{
                self.displayMessage(userMessage: "could not successfully perfom this request. please try again tater")
                print("error=\(String(describing: error))")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 401 {
                    print("error \(httpResponse.statusCode)")
                    self.displayMessage(userMessage: "This email alredy exist")
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
                    
                    let errorCode1 = parseJSON["error"] as? String
                    let errorCode = String(describing: errorCode1)
                    if  errorCode == "400"{
                        self.displayMessage(userMessage: errorCode)
                        return
                    }
                    
                    let userId = parseJSON["_id"] as? String
                    print("UserId=\(String(describing: userId))")
                    
                    if (userId?.isEmpty)!
                    {
                        self.displayMessage(userMessage: "could not succsessful")
                        return
                    }else{
                        self.displayMessage(userMessage: "Succsessful you are Register")
                    }
                }else{
                    self.displayMessage(userMessage: "could not succsessful")
                }
                
            }catch {
            self.removeActivityyIndicator(activityIndicator: myActivityIndicator)
            
            self.displayMessage(userMessage: "could \(error)")
            print(error)
            }
        }
        task.resume()
    }
    
  
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
          self.view.endEditing(true)
          return false
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
            }
            
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion: nil)
            
        }
    }
 


}

