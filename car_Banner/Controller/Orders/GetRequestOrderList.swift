//
//  GetRequestOrderList.swift
//  car_Banner
//
//  Created by максим теодорович on 02.11.2019.
//  Copyright © 2019 максим теодорович. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper

class getReguestOrderList {
    var numOfItems: Int = 0
    var companyName: [String] = []
    var errorP: Int = 0
    
    init() {
         let accessToken: String? = KeychainWrapper.standard.string(forKey: "accessToken")

               let myUrl                = URL(string: "http://d4aca7af.ngrok.io/api/order/listOrders")
               var request              = URLRequest(url: myUrl!)
               request.httpMethod       = "GET"
               request.addValue("application/json", forHTTPHeaderField: "content-type")
               request.addValue("\(accessToken!)", forHTTPHeaderField: "auth-token")
               
               let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
               
                   if error != nil{
                       self.errorP = 404
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
                                       self.numOfItems = parseJSON.count
                                       for i in 0..<parseJSON.count {
                                           let addData: String = ((parseJSON[i] as AnyObject).object(forKey: "companyName") as? String)!
                                           self.companyName.append(addData)
                                           print(self.companyName[i])
                                       }
                                   }
                           } else {
                               self.errorP = 404
                           }
                               
                       } catch {
                           
                           self.errorP = 404
                           print(error)
                       }
               }
               task.resume()
    }
}
