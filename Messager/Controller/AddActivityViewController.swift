//
//  AddActivityViewController.swift
//  Messager
//
//  Created by Boyang Zhang on 9/10/20.
//

import UIKit

class ActivityViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
    }
    
    
    func setupUI() {
        self.tabBarController?.tabBar.isHidden = false

    }

   
    
    
    @IBAction func backBttnTapped(_ sender: UIButton) {
        self.tabBarController?.selectedIndex = 0

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
