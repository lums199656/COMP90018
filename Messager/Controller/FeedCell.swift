//
//  FeedCell.swift
//  Messager
//
//  Created by zhangchongjing on 2020/10/9.
//

import UIKit
import Firebase
import DOFavoriteButtonNew

class FeedCell: UITableViewCell {
    @IBOutlet weak var profile5: UIImageView!
    @IBOutlet weak var profile4: UIImageView!
    @IBOutlet weak var profile3: UIImageView!
    @IBOutlet weak var profile2: UIImageView!
    @IBOutlet weak var profile1: UIImageView!
    @IBOutlet weak var labelD: UILabel!
    @IBOutlet weak var labelT: UILabel!
    @IBOutlet weak var feedImage: UIImageView!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var bbb: DOFavoriteButtonNew! //heart btn
    @IBOutlet weak var errorView: UIImageView!
    
    
    let storage = Storage.storage()
    let db = Firestore.firestore()
    
    var cellData : FeedData!{
    //monitor, reocrd change
        didSet{
            bbb.addTarget(self, action: #selector(self.tappedButton), for: .touchUpInside)
            labelT.text = cellData.title
            labelD.text = cellData.detail
            
            //text adaption
            labelD.numberOfLines=0
            labelD.lineBreakMode = NSLineBreakMode.byWordWrapping
            
            //get feed image
            let imageId : String! = cellData!.image
            let cloudFileRef = storage.reference(withPath: "activity-images/"+imageId)
            print("activity-images/"+imageId)
            //cloudFileRef.write(toFile: )
            cloudFileRef.getData(maxSize: 1*1024*1024) { (data, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    self.feedImage.image = UIImage(data: data!)
                }
            }
            
            let joins:[String] = cellData!.join //for get profile array
            print("joins")
            print(joins)
            var cur = 1
            profile5.image = nil
            profile4.image = nil
            profile3.image = nil
            profile2.image = nil
            profile1.image = nil
            for join in joins{
                self.db.collection("User").whereField("id", isEqualTo: join).getDocuments{ (querySnapshot, error) in
                    if let e = error{
                        print("error happens in getDocuments\(e)" )
                    }
                    else{
                        if let snapShotDocuments = querySnapshot?.documents{
                            for doc in snapShotDocuments{
                                let data = doc.data()
                                //add profile to arr
                                let pic = data["avatarLink"] as! String
                                let proRef = self.storage.reference(withPath: "user-photoes/"+pic)
                                print("user-photoes/"+pic)
                                proRef.getData(maxSize: 1*1024*1024) { (data, error) in
                                    if let error = error {
                                        print(error.localizedDescription)
                                    } else {
                                        switch cur {
                                        case 1:
                                            self.profile1.image = UIImage(data: data!)
                                            cur+=1
                                            break
                                        case 2:
                                            self.profile2.image = UIImage(data: data!)
                                            cur+=1
                                            break
                                        case 3:
                                            self.profile3.image = UIImage(data: data!)
                                            cur+=1
                                            break
                                        case 4:
                                            self.profile4.image = UIImage(data: data!)
                                            cur+=1
                                            break
                                        case 5:
                                            self.profile5.image = UIImage(data: data!)
                                            cur+=1
                                            break
                                        default:
                                            cur = 1
                                            break
                                        }
                                    }
                                }
                            }
                        }//snapshot
                    }
                }
                cur = 1
            }
//            if(p1 != ""){
//                let proRef = storage.reference(withPath: "user-photoes/"+p1)
//                print("user-photoes/"+p1)
//                proRef.getData(maxSize: 1*1024*1024) { (data, error) in
//                    if let error = error {
//                        print(error.localizedDescription)
//                    } else {
//                        self.profile1.image = UIImage(data: data!)
//                        //self.test.image = UIImage(data: data!)
//                    }
//                }
//            }
//            if(p2 != ""){
//                let proRef = storage.reference(withPath: "user-photoes/"+p2)
//                print("user-photoes/"+p2)
//                proRef.getData(maxSize: 1*1024*1024) { (data, error) in
//                    if let error = error {
//                        print(error.localizedDescription)
//                    } else {
//                        self.profile2.image = UIImage(data: data!)
//                    }
//                }
//            }
        }
    }
    
    //tap action
    @objc func tappedButton(sender: DOFavoriteButtonNew) {
        if sender.isSelected {
            sender.deselect()
            print("dislike")
            removeUser()
        } else {
            upLoadUserToJoinList()
            print("like")
        }
    }
    
    //logic for add user in join field
    func upLoadUserToJoinList(){
        let docRef = db.collection(K.FStore.act).document(cellData.uid!)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let max:Int = document.data()!["actGroupSize"] as! Int
                let joinArr:[String] = document.data()!["join"] as! [String]
                let cur_num = joinArr.count
                if cur_num < max {
                    if cur_num+1 == max{
                        self.db.collection(K.FStore.act).document(self.cellData.uid!).updateData(["join": FieldValue.arrayUnion([self.cellData.user]), "actStatus":1]) //join user in firebase and change status
                    }
                    else{
                        self.db.collection(K.FStore.act).document(self.cellData.uid!).updateData(["join": FieldValue.arrayUnion([self.cellData.user])]) //join user in firebase
                    }
                    self.bbb.select()
                }
                else{
                    //change status. use update! instead of setData
                    self.db.collection(K.FStore.act).document(self.cellData.uid!).updateData(["actStatus": 1])
                    print("full")
                    
                    //animation
                    self.errorView.isHidden = false
                    self.errorView.alpha = 1.0
                    UIView.animate(withDuration: 0.5, delay: 2.0, options: [], animations: {
                        self.errorView.alpha = 0.0
                    }) { (finished: Bool) in
                        self.errorView.isHidden = true
                    }
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    //logic for dislike
    func removeUser(){
        let docRef = db.collection(K.FStore.act).document(cellData.uid!)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let status:Int = document.data()!["actStatus"] as! Int
                if status != 0 {
                    self.db.collection(K.FStore.act).document(self.cellData.uid!).updateData(["join": FieldValue.arrayRemove([self.cellData.user]), "actStatus":0]) //remove user in firebase and change status to 0
                }
                else{
                    self.db.collection(K.FStore.act).document(self.cellData.uid!).updateData(["join": FieldValue.arrayRemove([self.cellData.user])]) //remove user in firebase
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
