//
//  MeViewController.swift
//  Messager
//
//  Created by Hui on 2020/10/10.
//

import UIKit
import Firebase
import FirebaseUI

class MeViewController: UIViewController, UITableViewDataSource,UIScrollViewDelegate {
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    // data source of activities
    var createdLists: [ActivityData] = []
    var joinedLists: [ActivityData] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count: Int?
        if tableView == self.firstView{
            count = createdLists.count
        }
        if tableView == self.secondView{
            count = joinedLists.count
        }
        return count!
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var tableCell: UITableViewCell?
        if tableView == self.firstView{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CreatedCell", for: indexPath) as! CreatedCell
            cell.cellData = createdLists[indexPath.row]
            tableCell = cell
        }
        if tableView == self.secondView{
            let cell = tableView.dequeueReusableCell(withIdentifier: "JoinedCell", for: indexPath) as! JoinedCell
            cell.cellData = joinedLists[indexPath.row]
            tableCell = cell
        }
        return tableCell ?? UITableViewCell()
    }
    
    
    // change table views in personal page
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var firstView: UITableView!
    @IBOutlet weak var secondView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBAction func changePage(_ sender: UISegmentedControl) {
        
        let x = CGFloat(sender.selectedSegmentIndex) * scrollView.bounds.width
        let offset = CGPoint(x: x, y: 0)
        scrollView.setContentOffset(offset, animated: true)
    }
    
    //automatically update segment index
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x / firstView.bounds.width)
        print(firstView.bounds.width)
        segmentedControl.selectedSegmentIndex = index
        print(segmentedControl.selectedSegmentIndex)
        print(scrollView.contentOffset)
        
    }
    
    @IBOutlet weak var PhotoContainer: UIView!
    
    // MARK:- View Controller LifeCycle
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
        super.viewWillAppear(animated)
        self.loadInfo()
        createdLists = []
        joinedLists = []
        self.getActivities()
        // toggle tabbar
        print("😡")
        if let vcp = self.navigationController?.parent as? TabViewController {
            print("😃")
            vcp.showTabBar()
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        super.viewWillDisappear(animated)
        
        // toggle tabbar
        print("😡")
        if let vcp = self.navigationController?.parent as? TabViewController {
            print("😃")
            vcp.hideTabBar()
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        //setUI()
        //Fatal error: Unexpectedly found nil while implicitly unwrapping an Optional value: file
        // Do any additional setup after loading the view.
        //self.loadInfo()
        //self.getActivities()
        
    }
    
    // MARK:-
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userLocation: UILabel!
    @IBOutlet weak var userIntro: UILabel!
    func loadInfo() {
        let user = Auth.auth().currentUser
        if let user = user {
            let userInfo = db.collection("User")
            let query = userInfo.whereField("id", isEqualTo: user.uid)
            query.getDocuments { [self] (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        let image = data["avatarLink"] as! String
                        let intro = data["intro"] as! String
                        let location = data["location"] as! String
                        let name = data["username"] as! String
                        self.userIntro.text = intro
                        self.userLocation.text = location
                        self.userName.text = name
                        let cloudFileRef = self.storage.reference(withPath: "user-photoes/"+image)
                        self.userImage.sd_setImage(with: cloudFileRef)
                        print("TEST:      loooking foooooor imaaaaaaage")
                    }
                }
            }
        }
    }
    
    func getActivities() {
        self.createdLists = []
        self.joinedLists = []
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        //获取数据
        guard let id = Auth.auth().currentUser?.uid else { return }
        db.collection(K.FStore.act).getDocuments() { [self] (querySnapshot, error) in
            if let e = error{
                print("error happens in getDocuments\(e)" )
            }
            else{
                if let snapShotDocuments = querySnapshot?.documents{
                    for doc in snapShotDocuments{
                        let data = doc.data()
                        let starterID = data["actCreatorId"] as? String
                        let joinUsers = data["join"] as? [String]
                        let title = data[K.Activity.title] as? String
                        let image = data[K.Activity.image] as? String
                        let activityID = doc.documentID as? String
                        let dateLong = data["startDate"] as? Timestamp
                        let date = dateLong?.dateValue() as? Date
                        var dateString = ""
                        if date != nil {
                            dateString = df.string(from: date!)
                        }
                        
                        
                        let feedData = ActivityData(title: title ?? "", image: image ?? "error.jpg", date: dateString, activityID: activityID ?? "")
                        if id == starterID {
                            self.createdLists.append(feedData)
                        }
                        
                        if let joinCount = joinUsers?.count {
                            if joinCount > 1 {
                                if ((joinUsers?[1...].contains(id)) != nil && joinUsers![1...].contains(id)) {
                                    self.joinedLists.append(feedData)
                                }
                            }
                        }
                    }
                    self.firstView.reloadData()
                    self.secondView.reloadData()
                }
            }
            
        }
    }
    
}

extension MeViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondVC = storyboard.instantiateViewController(identifier: "ActivityDetail") as ActivityDetailController

        if tableView == self.firstView{
            secondVC.activityID = createdLists[indexPath.row].activityID
            // show(secondVC, sender: self)
        }
        if tableView == self.secondView {
            secondVC.activityID = joinedLists[indexPath.row].activityID
        }
        self.navigationController?.show(secondVC, sender: self)
    }
}
