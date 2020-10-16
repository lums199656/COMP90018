//
//  PostViewController2.swift
//  Messager
//
//  Created by Boyang Zhang on 16/10/20.
//

import UIKit

class PostViewController2: UIViewController {

    override func viewDidLoad() {
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
    @IBAction func backBttnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        print("wwwdw")
    }
    
}
