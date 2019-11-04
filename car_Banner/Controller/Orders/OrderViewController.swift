//
//  OrderViewController.swift
//  car_Banner
//
//  Created by максим теодорович on 04.11.2019.
//  Copyright © 2019 максим теодорович. All rights reserved.
//

import UIKit

class OrderViewController: UIViewController {
    @IBOutlet weak var orderImage: UIImageView!
    @IBOutlet weak var orderNameCompany: UILabel!
    
    var image = UIImage()
    var orderCompanyNameParse = ""
    
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
