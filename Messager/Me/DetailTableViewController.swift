//
//  DetailTableViewController.swift
//  Messager
//
//  Created by Hui on 2020/11/7.
//

import UIKit
import Firebase
import ButtonEnLargeClass
import MapKit
import FirebaseUI
import FirebaseFirestore


class DetailTableViewController: UIView {
    var activityID = ""
    var starterUser = ""
    var activityTitleText = ""
    var category = ""
    var startDate:Date?
    var endDate :Date?
    let db = Firestore.firestore()
    let storage = Storage.storage()
    var userList = [User]()
    
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var startGroupChatButton: UIButton!

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var activityTitle: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var toDate: UILabel!
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
    @IBOutlet weak var starterButton: UIButton!
    @IBOutlet weak var p1Button: UIButton!
    @IBOutlet weak var p2Button: UIButton!
    @IBOutlet weak var p3Button: UIButton!
    @IBOutlet weak var p4Button: UIButton!
    @IBOutlet weak var noParticipants: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Detail"
        editButton.isHidden = true
        startGroupChatButton.isHidden = true
        p1Image.isHidden = true
        p2Image.isHidden = true
        p3Image.isHidden = true
        p4Image.isHidden = true
        p1Name.isHidden = true
        p2Name.isHidden = true
        p3Name.isHidden = true
        p4Name.isHidden = true
        p1Button.isHidden = true
        p2Button.isHidden = true
        p3Button.isHidden = true
        p4Button.isHidden = true
        self.noParticipants.isHidden = false
        scrollView.contentSize = CGSize(width: 320, height: 1200)

//        loadData()
        //let starterButton = UIButton.init(type: .custom)
        //starterButton.setEnLargeEdge(20,20,414,414)
    }
    
    
    

    @IBAction func startGroupChat(_ sender: Any) {
        for i in userList {
            print(i.username)
        }
        self.startActivityChat(users: userList, activityId: activityID)
    }
    
    func startActivityChat(users:[User], activityId: String) {
        let chatId = startChat(users: users, activityId: activityId, activityTitle: activityTitleText)
        print("_x start chat", chatId)
        var recipientId : [String] = []
        var recipientName : [String] = []
        for user in users {
            recipientId.append(user.id)
            recipientName.append(user.username)
        }
        // 打开一个 chat room 界面
        let privateChatView = ChatViewController(chatId: chatId, recipientId: recipientId, recipientName: recipientName, isActivity: true)
        privateChatView.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(privateChatView, animated: true)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadData()
    }

    
//    @IBAction func toStarter(_ sender: Any) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let starterVC = storyboard.instantiateViewController(identifier: "OtherUserVC") as OtherUserViewController
//        starterVC.currentUserID = userList[0].id
//        print(userList[0].id)
//        self.navigationController!.show(starterVC, sender: self)
//    }
    @IBAction func toParticipater(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let starterVC = storyboard.instantiateViewController(identifier: "OtherUserVC") as OtherUserViewController
        if (sender as! NSObject) == self.starterButton{
            starterVC.currentUserID = userList[0].id
        }
        if (sender as! NSObject) == self.p1Button{
            starterVC.currentUserID = userList[1].id
        }
        if (sender as! NSObject) == self.p2Button{
            starterVC.currentUserID = userList[2].id
        }
        if (sender as! NSObject) == self.p3Button{
            starterVC.currentUserID = userList[3].id
        }
        if (sender as! NSObject) == self.p4Button{
            starterVC.currentUserID = userList[4].id
        }
        print("starterVC.currentUserID: \(starterVC.currentUserID)")
        self.navigationController?.show(starterVC, sender: self)
    }
    
    @IBAction func edit(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let editVC = storyboard.instantiateViewController(withIdentifier: "editActivity") as? EditActivityController else {  return }
        editVC.activityID = self.activityID
        editVC.image = self.image.image
        editVC.titleAct = self.activityTitle.text!
        editVC.detail = self.details.text!
        editVC.locationStr = self.location.text!
        editVC.category = self.category
        editVC.startDate = self.startDate
        editVC.endDate = self.endDate
        
        editVC.modalPresentationStyle = .fullScreen
        self.present(editVC, animated: true, completion: nil)
    }
    
    
    
    func loadData() {
        print("ID 现在是：\(activityID)")
        userList = []
        let docRef = db.collection(K.FStore.act).document(activityID)
        docRef.getDocument { [self] (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                self.activityTitle.text = data?[K.Activity.title] as? String
                self.activityTitleText = self.activityTitle.text!
                let image = data![K.Activity.image] as! String
                // read date later
                self.date.text = ""
                let starterId = data!["actCreatorId"] as? String
                if starterId == Auth.auth().currentUser?.uid {
                    self.editButton.isHidden = false
                    self.startGroupChatButton.isHidden = false
                }
                self.details.text = data!["actDetail"] as? String
                self.location.text = data!["locationString"] as? String ?? "Online"
                let df = DateFormatter()
                df.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let dateLong = data!["startDate"] as! Timestamp
                let date = dateLong.dateValue() as! Date
                self.date.text = df.string(from: date)
                let todateLong = data!["endDate"] as! Timestamp
                let todate = todateLong.dateValue() as! Date
                self.toDate.text = df.string(from: todate)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "E, d MMM yyyy HH:mm"
                self.startDate = date
                self.endDate = todate
                
                self.category = data!["category"] as! String

                
                let joins = data![K.Activity.join] as! [String] //String array
                
                let userInfo = self.db.collection("User")
                let query = userInfo.whereField("id", isEqualTo: starterId)
                query.getDocuments { [self] (querySnapshot, error) in
                            if let error = error {
                                print("Error getting documents: \(error)")
                            } else {
                                for document in querySnapshot!.documents {
                                    let data = document.data()
                                    let uimage = data["avatarLink"] as! String
                                    let name = data["username"] as! String
                                    self.starterName.text = name
                                    let cloudFileRef = self.storage.reference(withPath: "user-photoes/"+uimage)
                                    self.starterImage.sd_setImage(with: cloudFileRef)
                                    var user = User()
                                    user.avatarLink = data["avatarLink"] as! String
                                    user.username = data["username"] as! String
                                    user.email = data["email"] as! String
                                    user.id = data["id"] as! String
                                    user.intro = data["intro"] as! String
                                    user.location = data["location"] as! String
                                    user.pushId = data["pushId"] as! String
                                    user.status = data["status"] as! String
                                    userList.append(user)
                            }
                                //find userInfo for join list, Chongjing Part
                                for join in joins[1...] {
                                    let query = userInfo.whereField("id", isEqualTo: join)
                                    query.getDocuments { [self] (querySnapshot, error) in
                                                if let error = error {
                                                    print("Error getting documents: \(error)")
                                                } else {
                                                    print("_x-43 len-document is: \(querySnapshot!.documents.count)")
                                                    for document in querySnapshot!.documents {
                                                        let data = document.data()
                                                        var user = User()
                                                        user.avatarLink = data["avatarLink"] as! String
                                                        user.username = data["username"] as! String
                                                        user.email = data["email"] as! String
                                                        user.id = data["id"] as! String
                                                        user.intro = data["intro"] as! String
                                                        user.location = data["location"] as! String
                                                        user.pushId = data["pushId"] as! String
                                                        user.status = data["status"] as! String
                                                        userList.append(user)
                                                        loadJoinData()

                                                    }
                                                }
                                    }
                                }
                        }
                }
                
                
                
                let cloudFileRef = self.storage.reference(withPath: "activity-images/"+image)
                self.image.sd_setImage(with: cloudFileRef)
                
                
                        
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func loadJoinData() {
        let userNum = userList.count
        if userNum > 1 {
            self.p1Name.text = userList[1].username
            let cloudFileRef = self.storage.reference(withPath: "user-photoes/"+userList[1].avatarLink)
            self.p1Image.sd_setImage(with: cloudFileRef)
            self.p1Name.isHidden = false
            self.p1Image.isHidden = false
            self.p1Button.isHidden = false
            self.noParticipants.isHidden = true
            print(userList)
        }
        if userNum > 2 {
            self.p2Name.text = userList[2].username
            let cloudFileRef = self.storage.reference(withPath: "user-photoes/"+userList[2].avatarLink)
            self.p2Image.sd_setImage(with: cloudFileRef)
            self.p2Name.isHidden = false
            self.p2Image.isHidden = false
            self.p2Button.isHidden = false
        }
        if userNum > 3 {
            self.p3Name.text = userList[3].username
            let cloudFileRef = self.storage.reference(withPath: "user-photoes/"+userList[3].avatarLink)
            self.p3Image.sd_setImage(with: cloudFileRef)
            self.p3Name.isHidden = false
            self.p3Image.isHidden = false
            self.p3Button.isHidden = false
        }
        if userNum > 4 {
            self.p4Name.text = userList[4].username
            let cloudFileRef = self.storage.reference(withPath: "user-photoes/"+userList[4].avatarLink)
            self.p4Image.sd_setImage(with: cloudFileRef)
            self.p4Name.isHidden = false
            self.p4Image.isHidden = false
            self.p4Button.isHidden = false
        }
    }
}
