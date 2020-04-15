//
//  FirstScreenViewController.swift
//  car_Banner
//
//  Created by Fire God on 23.03.2020.
//  Copyright © 2020 максим теодорович. All rights reserved.
//

import UIKit

class FirstScreenViewController: UIViewController {
    @IBOutlet weak var LogInButton: UIButton!
    @IBOutlet weak var RegisterButton2: UIButton!
//    @IBAction func RegisterButton(_ sender: UIButton) {
//        print("Register Button")
//
//        let RegisterUserViewController = self.storyboard?.instantiateViewController(withIdentifier: "RegisterUserViewController") as!  RegisterUserViewController
//
//        self.present(RegisterUserViewController,animated: true)
//    }
    
    override func viewDidLoad() {
        Settings.shered.buttonsParametrs(obj: LogInButton, rad: 25)
        Settings.shered.buttonsParametrs(obj: RegisterButton2, rad: 25)

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
