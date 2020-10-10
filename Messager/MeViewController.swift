//
//  MeViewController.swift
//  Messager
//
//  Created by Hui on 2020/10/10.
//

import UIKit
import Firebase


class MeViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
  // data source of created activities
    var activities = ["活动1","活动2","活动3","活动4","活动5","活动6","活动7","活动8"]
    var imageofactivities = UIImage(named:"WechatIMG1.jpg")
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreatedCell", for: indexPath) as! CreatedCell
        cell.activityLabel.text = activities[indexPath.row]
        cell.dateLabel.text = "everyday is sunday"
        cell.imageLabel.image = imageofactivities
        return cell
    }
    // data source of joined activities  BUG!!!
    var joinedactivities = ["活动1","活动2","活动3","活动4","活动5","活动6","活动7","活动8"]
    var joinedimageofactivities = UIImage(named:"WechatIMG2.jpg")
    func joinedtableView(_ joinedtableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return joinedactivities.count
    }
    func joinedtableView(_ joinedtableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let joinedcell = joinedtableView.dequeueReusableCell(withIdentifier: "JoinedCell", for: indexPath) as! JoinedCell
        joinedcell.activityLabel.text = joinedactivities[indexPath.row]
        joinedcell.dateLabel.text = "everyday is sunday"
        joinedcell.imageLabel.image = joinedimageofactivities
        return joinedcell
    }
    
    // change table views in personal page
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var firstView: UITableView!
    @IBOutlet weak var secondView: UITableView!
    @IBAction func indexChanged(sender: UISegmentedControl) {
           switch segmentedControl.selectedSegmentIndex
           {
           case 0:
            firstView.isHidden = false
            secondView.isHidden = false
           case 1:
            firstView.isHidden = false
            secondView.isHidden = false
           default:
               break;
           }
       }
    @IBOutlet weak var PhotoContainer: UIView!
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        PhotoContainer.layer.cornerRadius = PhotoContainer.frame.size.width / 2
//        PhotoContainer.clipsToBounds = true
//        firstView.layer.cornerRadius = 20
//        firstView.clipsToBounds = true
//        secondView.layer.cornerRadius = 20
//        secondView.clipsToBounds = true
//        // Do any additional setup after loading the view.
//    }

    @IBAction func exitToHere(sender: UIStoryboardSegue){
        //
    }
    
    @IBAction func saveAndExit(sender: UIStoryboardSegue){
        // save

    }
    
    @IBAction func configClicked(_ sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle:nil)
        let vc = sb.instantiateViewController(withIdentifier: "SecondViewController")
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func logOut(_ sender: Any) {
        FirebaseUserListener.shared.logOutCurrentUser{ (error) in
            if error == nil {
                let loginView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "loginView")
                
                DispatchQueue.main.async {
                    loginView.modalPresentationStyle = .fullScreen
                    self.present(loginView, animated: true, completion: nil)
                }
            }
        }
    }
}
