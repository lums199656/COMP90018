//
//  AddActivityViewController.swift
//  Messager
//
//  Created by Boyang Zhang on 8/10/20.
//

import UIKit

class AddActivityViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    func setupUI() {
        // Tab Bar Item
        self.tabBarController?.tabBar.isHidden = true
        
        // Nav Bar Item
//        self.navigationController?.navigationItem.backBarButtonItem.set
    }
    

    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
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
