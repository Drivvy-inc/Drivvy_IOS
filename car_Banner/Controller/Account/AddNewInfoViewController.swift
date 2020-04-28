//
//  AddNewInfoViewController.swift
//  car_Banner
//
//  Created by максим теодорович on 25.10.2019.
//  Copyright © 2019 максим теодорович. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class AddNewInfoViewController: UIViewController {
    @IBOutlet weak var UserCarField: UITextField!
    @IBOutlet weak var UserKmField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    let accessToken: String? = KeychainWrapper.standard.string(forKey: "accessToken")
    let userId: String?      = KeychainWrapper.standard.string(forKey: "userId")

    @IBAction func ConfirmDataButtonClicked(_ sender: Any) {
        if (UserCarField.text?.isEmpty)! ||
           (UserKmField.text?.isEmpty)! {
               return displayMessage(userMessage: "All fields are quired to fill in!")
           }
        
        let myActivityIndicator    = UIActivityIndicatorView( style: UIActivityIndicatorView.Style.medium )
        myActivityIndicator.center = view.center
        myActivityIndicator.hidesWhenStopped = false
        myActivityIndicator.startAnimating()
        view.addSubview(myActivityIndicator)
        let endpoint = Settings.shered.endpoint

        let myUrl = URL(string: endpoint + "api/account/addInfo")

        
        var request              = URLRequest(url: myUrl!)
        request.httpMethod       = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.addValue("\(accessToken!)", forHTTPHeaderField: "auth-token")
        
        let postString = [
            "id": userId!,
            "car": UserCarField.text!,
            "km": UserKmField.text!] as [ String: String ]
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
// self.displayMessage(userMessage:"succ")OrderListPageViewController

                        DispatchQueue.main.async
                        {
                            let id   = parseJSON["_id"] as? String
                            if id! == self.userId {
                            self.removeActivityyIndicator(activityIndicator: myActivityIndicator)
                            self.displayMessage(userMessage: "SUCCSESFUL! You Verify Account" )
                            }
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
                    self.navigationController?.popToRootViewController(animated: true)
                    NotificationCenter.default.post(name: NSNotification.Name("Reload Account"), object: nil)
                    NotificationCenter.default.post(name: NSNotification.Name("Reload Order List"), object: nil)

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
