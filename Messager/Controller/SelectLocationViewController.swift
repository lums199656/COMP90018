//
//  SelectLocationViewController.swift
//  Messager
//
//  Created by Boyang Zhang on 18/10/20.
//

import UIKit

/// For passing value back when SelectLocation VC is dismissed
protocol SelectLocationDelegate {
    func updateLocation()
}


class SelectLocationViewController: UIViewController {
    
    var delegate: SelectLocationDelegate?
    

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

}
