//
//  ActivityDetailController.swift
//  Messager
//
//  Created by 王品 on 2020/10/22.
//

import UIKit

class ActivityDetailController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var details: UILabel!
    
    @IBOutlet weak var starterImage: UIImageView!
    @IBOutlet weak var starterName: UILabel!
    
    @IBOutlet weak var p1Image: UIImageView!
    @IBOutlet weak var p1Name: UILabel!
    @IBOutlet weak var p2Image: UIImageView!
    @IBOutlet weak var p2Name: UILabel!
    @IBOutlet weak var p3Image: UIImageView!
    @IBOutlet weak var p3Name: UILabel!
    @IBOutlet weak var p4Image: UIImageView!
    @IBOutlet weak var p4Name: UILabel!
    
    
    
    @IBAction func startGroupChat(_ sender: Any) {
        
        
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
