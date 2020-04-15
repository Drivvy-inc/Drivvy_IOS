//
//  OrderListPageViewController.swift
//  car_Banner
//
//  Created by максим теодорович on 18.10.2019.
//  Copyright © 2019 максим теодорович. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Alamofire

class OrderListPageViewController: UIViewController{
    @IBOutlet weak var CollectioViewOrderList: UICollectionView!
    var refresher:UIRefreshControl!
    
    let myRefreshControl: UIRefreshControl = {
       let refreshControl = UIRefreshControl()
        let title = NSLocalizedString("Wait a second", comment: "Pull to refresh")
        refreshControl.tintColor = UIColor.black
        refreshControl.attributedTitle = NSAttributedString(string: title)
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        return refreshControl
    }()
    
    @objc func refresh(sender: UIRefreshControl) {
        self.CollectioViewOrderList.reloadData()
        companyName.removeAll()
        choise()
        sender.endRefreshing()
    }
    var status = ""
    var companyName: [String] = []
    var companyId: [String] = []
    let locationImages = [UIImage(named: "Uber"), UIImage(named: "Uklon"), UIImage(named: "scubaDiving"), UIImage(named: "Titan"), UIImage(named: "drivvi")]

    override func viewDidLoad() {
        super.viewDidLoad()
        CollectioViewOrderList.refreshControl = myRefreshControl
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: NSNotification.Name("Reload Order List"), object: nil)
        choise()
        // Do any additional setup after loading the view.
    }
    
    @objc func choise() {
        companyName.removeAll()
        self.CollectioViewOrderList.reloadData()
        switch status {
        case "":
            checkStatus()
        case "unverified":
            unverifiedMessage()
        default:
            companyName.removeAll()
            loadAllOrders()
        }
    }
    // MARK: - Function for load all Orders for user

    func loadAllOrders(){
        let accessToken: String? = KeychainWrapper.standard.string(forKey: "accessToken")
        let endpoint = Settings.shered.endpoint

        let myUrl                = URL(string: endpoint + "api/order/listOrders")

        var request              = URLRequest(url: myUrl!)
        request.httpMethod       = "GET"
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.addValue("\(accessToken!)", forHTTPHeaderField: "auth-token")
        
        
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) -> Void in
        
            if error != nil{
                self.displayMessage(userMessage: "Could not successfully perfom this request. please try again tater")
                print("error=\(String(describing: error))")
                return
            }
            
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 304{
                    print("statusCode: \(response.statusCode)")
                    return
                } else {
                    print("statusCode: \(response.statusCode)")
                }
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: [.mutableContainers]) as? NSMutableArray

                if let parseJSON = json{
    //                      self.displayMessage(userMessage: "succ")OrderListPageViewController

                            DispatchQueue.main.async
                            {
                                for i in 0..<parseJSON.count {
                                    let addData: String = ((parseJSON[i] as AnyObject).object(forKey: "companyName") as? String)!
                                    self.companyName.append(addData)
                                    print(self.companyName[i])
                                }
                                for i in 0..<parseJSON.count {
                                    let addData: String = ((parseJSON[i] as AnyObject).object(forKey: "_id") as? String)!
                                    self.companyId.append(addData)
                                    print(self.companyId[i])
                                }
                                self.CollectioViewOrderList.reloadData()
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
    
    // MARK: - checkStatus
    func checkStatus(){
        let accessToken: String? = KeychainWrapper.standard.string(forKey: "accessToken")
        let endpoint = Settings.shered.endpoint

        let url = URL(string: endpoint + "api/checkStatus")

        
        var request              = URLRequest(url: url!)
        request.httpMethod       = "POST"
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.addValue("\(accessToken!)", forHTTPHeaderField: "auth-token")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("error: \(error)")
            } else {
                if let response = response as? HTTPURLResponse {
                    print("statusCode: \(response.statusCode)")
                }
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print("data: \(dataString)")
                    self.status = dataString
                }
                DispatchQueue.main.async
                {
                    self.CollectioViewOrderList.reloadData()
                    self.viewDidLoad()
                }
            }
        }
        task.resume()
    }

    func unverifiedMessage(){
        self.companyName.append("Test")
        self.companyName.append("Uber")

        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        
        displayMessage(userMessage: "you not verified")
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
    @objc func reloadData(){
        companyName.removeAll()
        choise()
    }
}

// MARK: - OrderListPageViewController
extension OrderListPageViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return companyName.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! OrderListCollectionViewCell
        
        cell.locationImage.image = locationImages[indexPath.row]
        cell.locationName.text = companyName[indexPath.row]
                
        //This creates the shadows and modifies the cards a little bit
        cell.contentView.layer.cornerRadius = 4.0
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds = false
        cell.layer.shadowColor = UIColor.gray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        cell.layer.shadowRadius = 4.0
        cell.layer.shadowOpacity = 1.0
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let OrderViewController = self.storyboard?.instantiateViewController(withIdentifier: "OrderViewController") as!  OrderViewController

        OrderViewController.image = locationImages[indexPath.row]!
        OrderViewController.orderCompanyNameParse = companyName[indexPath.row]
        OrderViewController.orderCompanyIdParse = companyId[indexPath.row]

        self.present(OrderViewController,animated: true)
        
    }
}

