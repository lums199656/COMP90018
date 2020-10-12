//
//  MeViewController.swift
//  Messager
//
//  Created by Hui on 2020/10/10.
//

import UIKit
import Firebase


class MeViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
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
    private func setUI(){
        PhotoContainer.layer.cornerRadius = PhotoContainer.frame.size.width / 2
        PhotoContainer.clipsToBounds = true
        firstView.layer.cornerRadius = 20
        firstView.clipsToBounds = true
        secondView.layer.cornerRadius = 20
        secondView.clipsToBounds = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setUI()
        //Fatal error: Unexpectedly found nil while implicitly unwrapping an Optional value: file
        // Do any additional setup after loading the view.
        loadInfo()
    }
    

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userLocation: UILabel!
    @IBOutlet weak var userIntro: UILabel!
    func loadInfo() {
        let user = Auth.auth().currentUser
        if let user = user {
            let uid = user.uid
            let userInfo = db.collection("UserInfo")
            let query = userInfo.whereField("userID", isEqualTo: uid)
            query.getDocuments { [self] (querySnapshot, error) in
                        if let error = error {
                            print("Error getting documents: \(error)")
                        } else {
                            for document in querySnapshot!.documents {
                                let data = document.data()
                                let image = data["userImage"] as! String
                                let intro = data["userIntro"] as! String
                                let location = data["userLocation"] as! String
                                self.userIntro.text = intro
                                self.userLocation.text = location
                                let cloudFileRef = self.storage.reference(withPath: "user-photoes/"+image)
                                            print("user-photoes/"+image)
                                            cloudFileRef.getData(maxSize: 1*1024*1024) { (data, error) in
                                                if let error = error {
                                                    print(error.localizedDescription)
                                                } else {
                                                    self.userImage.image = UIImage(data: data!)
                                                }
                                            }

                            }
                        }
                    }
            let userAuth = db.collection("User")
            let queryUser = userAuth.whereField("id", isEqualTo: uid)
            queryUser.getDocuments { [self] (querySnapshot, error) in
                        if let error = error {
                            print("Error getting documents: \(error)")
                        } else {
                            for document in querySnapshot!.documents {
                                let data = document.data()
                                let name = data["username"] as! String
                                self.userName.text = name
                            }
                        }
                    }

        }
    }

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
    
}
