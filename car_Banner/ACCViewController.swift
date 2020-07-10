//
//  ACCViewController.swift
//  car_Banner
//
//  Created by Fire God on 22.06.2020.
//  Copyright © 2020 максим теодорович. All rights reserved.
//

import UIKit

class ACCViewController: ViewController {
    @IBOutlet weak var StackView: UIStackView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var Wallet: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var gpsView: UIView!
    @IBOutlet weak var pulseView: UIView!
    @IBOutlet weak var blackView: UIView!
    @IBOutlet weak var forGpsView: UIView!
    
    let borderAlpha : CGFloat = 0.7
    let cornerRadius : CGFloat = 15.0

    override func viewDidLoad() {
        StackView.addVerticalSeparators(color : .white)
        Wallet.tintColor =  UIColor.white
        Wallet.backgroundColor = UIColor.clear
        Wallet.layer.borderWidth = 1.0
        Wallet.layer.borderColor = UIColor(white: 1.0, alpha: borderAlpha).cgColor
        Wallet.layer.cornerRadius = cornerRadius
        Wallet.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.2)

        let new = gpsView.center
        let pulse = Pulsing(numberOfPulses: 60, radius: 40, position: gpsView.center)
        pulse.animationDuration = 1.2
        pulse.backgroundColor = UIColor.red.cgColor
        
        self.forGpsView.layer.insertSublayer(pulse, below: gpsView.layer)
        
//          var pulseAnimation:CABasicAnimation = CABasicAnimation(keyPath: "opacity")
//          pulseAnimation.duration = 5.0
//        pulseAnimation.fromValue = NSNumber(value: 0.0)
//        pulseAnimation.toValue = NSNumber(value: 1.0)
//        pulseAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
//          pulseAnimation.autoreverses = true
//          pulseAnimation.repeatCount = Float.infinity
//        gpsView.layer.add(pulseAnimation, forKey: "opacity")
        
        super.viewDidLoad()
      

        // Do any additional setup after loading the view.
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

extension UIStackView {
   func addVerticalSeparators(color : UIColor) {
        var i = self.arrangedSubviews.count
        while i > 1 {
            let separator = verticalCreateSeparator(color: color)
            insertArrangedSubview(separator, at: i-1)   // (i-1) for centers only
            separator.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1).isActive = true
            i -= 1
        }
    }

    private func verticalCreateSeparator(color : UIColor) -> UIView {
        let separator = UIView()
        separator.widthAnchor.constraint(equalToConstant: 1).isActive = true
        separator.backgroundColor = color
        return separator
    }
}

extension UIView{ func customAlertView(frame: CGRect, message: String, color: UIColor, startY: CGFloat, endY: CGFloat) -> UIView{

   //Adding label to view
   let label = UILabel()
   label.frame = CGRect(x: 0, y: 0, width: frame.width, height:70)
   label.textAlignment = .center
   label.textColor = .white
   label.numberOfLines = 0
   label.text = message
   self.addSubview(label)
   self.backgroundColor = color

   //Adding Animation to view
   UIView.animate(withDuration:0.5, delay: 0, options:
   [.curveEaseOut], animations:{
      self.frame = CGRect(x: 0, y: startY, width: frame.width, height: 64)
      }) { _ in
         UIView.animate(withDuration: 0.5, delay: 4, options: [.curveEaseOut], animations: {
               self.frame = CGRect(x: 0, y: endY, width: frame.width, height:64)
         }, completion: {_ in
             self.removeFromSuperview()
         })
      }
   return self
}
}
