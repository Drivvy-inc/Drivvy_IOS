//
//  Setings.swift
//  car_Banner
//
//  Created by Fire God on 23.03.2020.
//  Copyright © 2020 максим теодорович. All rights reserved.
//

import Foundation
import UIKit

class Settings{
    static let shered = Settings()
    
    var endpoint = "http://b6e31e15.ngrok.io/"
    
    func buttonsParametrs(obj: UIButton, rad: CGFloat) {
        
        obj.layer.cornerRadius = rad
        obj.clipsToBounds = true
        
    }
    private init(){}
}


 // MARK: - addBottomBorder
extension UITextField {
     func addBottomBorder(){
         let bottomLine = CALayer()
         bottomLine.frame = CGRect(x: 0, y: self.frame.size.height - 1, width: self.frame.size.width, height: 1)
         bottomLine.backgroundColor = UIColor.systemYellow.cgColor
         borderStyle = .none
         layer.addSublayer(bottomLine)
     }
 }
