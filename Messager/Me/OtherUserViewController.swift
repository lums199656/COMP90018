//
//  OtherUserViewController.swift
//  Messager
//
//  Created by Hui on 2020/10/19.
//

import UIKit
import Firebase


class OtherUserViewController: UIViewController, UITableViewDataSource,UIScrollViewDelegate {
    let db = Firestore.firestore()
    let storage = Storage.storage()
    var currentUserID = ""
    
    // data source of activities
    var createdLists : [ActivityData] = []
    var joinedactivities = ["活动1","活动2","活动3","活动4","活动5","活动6","活动7"]
    var joinedimageofactivities = UIImage(named:"avatar")
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count: Int?
        if tableView == self.firstView{
            count = createdLists.count
        }
        if tableView == self.secondView{
            count = joinedactivities.count
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
            cell.joinedActivity.text = joinedactivities[indexPath.row]
            cell.joinedDate.text = "2088-11-22"
            cell.joinedImage.image = joinedimageofactivities
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
            print(segmentedControl.selectedSegmentIndex)
            print(scrollView.contentOffset.x)
            segmentedControl.selectedSegmentIndex = index
            print(segmentedControl.selectedSegmentIndex)
            print(scrollView.contentOffset.x)

    }
    
    @IBOutlet weak var PhotoContainer: UIView!
    private func setUI(){
    //    PhotoContainer.layer.cornerRadius = PhotoContainer.frame.size.width / 2
    //    PhotoContainer.clipsToBounds = true
    //    firstView.layer.cornerRadius = 20
    //    firstView.clipsToBounds = true
    //    secondView.layer.cornerRadius = 20
    //    secondView.clipsToBounds = true
    }
    //  Hide First Page NavigationBar
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
        super.viewWillAppear(animated)
        self.loadInfo()
    }
    override func viewWillDisappear(_ animated: Bool) {
          navigationController?.setNavigationBarHidden(false, animated: true)
          super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setUI()
        //Fatal error: Unexpectedly found nil while implicitly unwrapping an Optional value: file
        // Do any additional setup after loading the view.
        self.loadInfo()
        self.getActivities()
    }
    
    

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userLocation: UILabel!
    @IBOutlet weak var userIntro: UILabel!
    func loadInfo() {
        let userUid = currentUserID
        if userUid == currentUserID {
            let userInfo = db.collection("User")
            let query = userInfo.whereField("id", isEqualTo: userUid)
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
        }
    }

    func getActivities() {
        //获取数据
        let id = currentUserID
        let query = db.collection(K.FStore.act).whereField("userId", isEqualTo: id)
        query.getDocuments { [self] (querySnapshot, error) in
            if let e = error{
                print("error happens in getDocuments\(e)" )
            }
            else{
                if let snapShotDocuments = querySnapshot?.documents{
                    for doc in snapShotDocuments{
                        let data = doc.data()
                        let title = data[K.Activity.title] as? String
                        let image = data[K.Activity.image] as? String
                        let activityID = data[K.Activity.uid] as? String
                        // read date later
                        let date = ""
                        
                        let feedData = ActivityData(title: title, image: image, date: date, activityID: activityID)
                        self.createdLists.append(feedData)
                        print(createdLists)

                    }
                    self.firstView.reloadData()
                }
            }

        }
    }

}

extension OtherUserViewController : UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        if tableView == self.firstView{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let secondVC = storyboard.instantiateViewController(identifier: "ActivityDetail") as ActivityDetailController
            secondVC.activityID = createdLists[indexPath.row].activityID!
            // show(secondVC, sender: self)
            self.navigationController?.show(secondVC, sender: self)
        }
    }
}

