//
//  FeedCell.swift
//  Messager
//
//  Created by zhangchongjing on 2020/10/9.
//

import UIKit
import Firebase
import DOFavoriteButtonNew
import FirebaseUI
import RealmSwift
import FirebaseFirestore

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
    //@IBOutlet weak var seeMoreBtn: UIButton!
    @IBOutlet weak var labelMaxUser: PatientInfoCustomLabel!
    
    let storage = Storage.storage()
    let db = Firestore.firestore()
    let realm = try! Realm()
    let cur_user = Auth.auth().currentUser!.uid
    var joinList = [String]()
    
    
    //cellData每一次变更都会出发didSet
    var cellData : FeedData!{
    //monitor, reocrd change
        didSet{
            //seeMoreBtn.isHidden = true
            joinList = cellData.join
            bbb.addTarget(self, action: #selector(self.tappedButton), for: .touchUpInside)
            var distance: String = ""
            if cellData.distance > 100 {
                distance = ">100KM"
            }
            else{
                distance = "\(cellData.distance!)KM"
            }
            let title: String = "[\(cellData.category.uppercased())] \(cellData.title!.uppercased())/ \(cellData.locationString.uppercased())/ \(distance)"
            labelT.text = title
            print("endDate is: \(cellData.endDate)")
            labelD.text = "End Date: \(cellData.endDate!)"
            labelMaxUser.text = "People: \(cellData.join.count)/\(cellData.groupSize!)"

            //text adaption
            labelT.numberOfLines=0
            labelT.lineBreakMode = NSLineBreakMode.byWordWrapping
            
            //get feed image
            let imageId : String! = cellData!.image
            let cloudFileRef = storage.reference(withPath: "activity-images/"+imageId)
            //print("===========================")
            print("activity-images/"+imageId)
            //print("===========================")
            feedImage.sd_setImage(with: cloudFileRef) //very quick function!
            
//            cloudFileRef.getData(maxSize: 1*1024*1024) { (data, error) in
//                if let error = error {
//                    print(error.localizedDescription)
//                } else {
//                    self.feedImage.image = UIImage(data: data!)
//                }
//            }
            
            //initiate like btn
            let s: String = "id = '"+cellData.uid!+"' AND user = '"+cellData.user!+"'"
            let predicate = NSPredicate(format: s)
            let likeBtn = realm.objects(LikeBtn.self).filter(predicate).first
            // if query doesn't exist, create one
            if likeBtn == nil{
                bbb.deselect()
                let lb = LikeBtn()
                lb.id = cellData.uid!
                lb.user = cellData.user!
                lb.select = false
                try! realm.write {
                    realm.add(lb)
                }
            }
            else{
                if likeBtn?.select == true{
                    bbb.select()
                }
                else{
                    bbb.deselect()
                }
            }
            let joins:[String] = cellData!.join //for get profile array
            print("joins is \(joins)")
            var cur = 1

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
                                print("\(cur). pic is: \(pic)")
                                let proRef = self.storage.reference(withPath: "user-photoes/"+pic)
                                print("user-photoes/"+pic)
                                switch cur {
                                case 1:
                                    self.profile1.sd_setImage(with: proRef)
//                                    self.profile1.layer.borderWidth = 1
//                                    self.profile1.layer.borderColor = UIColor.black.cgColor
                                    self.profile2.image = nil
                                    self.profile3.image = nil
                                    self.profile4.image = nil
                                    self.profile5.image = nil
                                    cur+=1
                                    break
                                case 2:
                                    self.profile2.sd_setImage(with: proRef)
//                                    self.profile2.layer.borderWidth = 1
//                                    self.profile2.layer.borderColor = UIColor.black.cgColor
                                    cur+=1
                                    break
                                case 3:
                                    self.profile3.sd_setImage(with: proRef)
//                                    self.profile3.layer.borderWidth = 1
//                                    self.profile3.layer.borderColor = UIColor.black.cgColor
                                    cur+=1
                                    break
                                case 4:
                                    self.profile4.sd_setImage(with: proRef)
//                                    self.profile4.layer.borderWidth = 1
//                                    self.profile4.layer.borderColor = UIColor.black.cgColor
                                    cur+=1
                                    break
                                case 5:
                                    self.profile5.sd_setImage(with: proRef)
//                                    self.profile5.layer.borderWidth = 1
//                                    self.profile5.layer.borderColor = UIColor.black.cgColor
                                    cur+=1
                                    break
                                default:
                                    cur = 1
                                    break
                                }
                            }
                        }//snapshot
                    }
                }
                cur = 1
            }
        }
    }
    
    //tap action
    @objc func tappedButton(sender: DOFavoriteButtonNew) {
        let s: String = "id = '"+cellData.uid!+"' AND user = '"+cellData.user!+"'"
        let predicate = NSPredicate(format: s)
        let likeBtn = realm.objects(LikeBtn.self).filter(predicate).first
        if sender.isSelected {
            removeUserProfile()
            sender.deselect()
            try! realm.write {
                likeBtn!.select = false
            }
            print("dislike")
            removeUser()
        } else {
            addUserProfile() //add cur user profile into list
            upLoadUserToJoinList()
            try! realm.write {
                likeBtn!.select = true
            }
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
                        self.db.collection(K.FStore.act).document(self.cellData.uid!).updateData(["join": FieldValue.arrayUnion([self.cur_user]), "actStatus":1]) //join user in firebase and change status
                    }
                    else{
                        self.db.collection(K.FStore.act).document(self.cellData.uid!).updateData(["join": FieldValue.arrayUnion([self.cur_user])]) //join user in firebase
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
                    self.db.collection(K.FStore.act).document(self.cellData.uid!).updateData(["join": FieldValue.arrayRemove([self.cur_user]), "actStatus":0]) //remove user in firebase and change status to 0
                }
                else{
                    self.db.collection(K.FStore.act).document(self.cellData.uid!).updateData(["join": FieldValue.arrayRemove([self.cur_user])]) //remove user in firebase
                }
            }
        }
    }
    
    func removeUserProfile() {
        if !joinList.contains(cur_user) {
            let count = joinList.count+1
            switch count {
            case 1:
                self.profile1.image = nil
            case 2:
                self.profile2.image = nil
            case 3:
                self.profile3.image = nil
            case 4:
                self.profile4.image = nil
            case 5:
                self.profile5.image = nil
            default:
                break
            }
        }
        else{
            var index = 0
            for join in cellData.join {
                index += 1
                if join==cur_user {
                    break
                }
            }
            let remove_index = index - 1
//            while index<=joinList.count + 1 {
//                switch index {
//                case 1:
//                    self.profile1.image = self.profile2.image
//                    index+=1
//                case 2:
//                    self.profile2.image = self.profile3.image
//                    index+=1
//                case 3:
//                    self.profile3.image = self.profile4.image
//                    index+=1
//                case 4:
//                    self.profile4.image = self.profile5.image
//                    index+=1
//                case 5:
//                    self.profile5.image = nil
//                    index+=1
//                default:
//                    index+=1
//                    break
//                }
//            }
            cellData.join.remove(at: remove_index)
        }
        labelMaxUser.text = "People: \(joinList.count)/\(cellData.groupSize!)"
    }
    
    func addUserProfile() {
        var count = joinList.count + 1
        let docRef = db.collection("User").document(cur_user)
        docRef.getDocument { [self] (document, error) in
            if let document = document, document.exists {
                let pic = document.data()!["avatarLink"] as! String
                let proRef = self.storage.reference(withPath: "user-photoes/"+pic)
                switch count {
                case 1:
                    self.profile1.sd_setImage(with: proRef)
                    let animation = CABasicAnimation(keyPath: "opacity")
                    animation.fromValue = 0.0
                    animation.toValue = 1.0
                    animation.duration = 0.5
                    self.profile1.layer.add(animation, forKey: "Image-opacity")
                    break
                case 2:
                    self.profile2.sd_setImage(with: proRef)
                    let animation = CABasicAnimation(keyPath: "opacity")
                    animation.fromValue = 0.0
                    animation.toValue = 1.0
                    animation.duration = 0.5
                    self.profile2.layer.add(animation, forKey: "Image-opacity")
                    break
                case 3:
                    self.profile3.sd_setImage(with: proRef)
                    let animation = CABasicAnimation(keyPath: "opacity")
                    animation.fromValue = 0.0
                    animation.toValue = 1.0
                    animation.duration = 0.5
                    self.profile3.layer.add(animation, forKey: "Image-opacity")
                    break
                case 4:
                    self.profile4.sd_setImage(with: proRef)
                    let animation = CABasicAnimation(keyPath: "opacity")
                    animation.fromValue = 0.0
                    animation.toValue = 1.0
                    animation.duration = 0.5
                    self.profile4.layer.add(animation, forKey: "Image-opacity")
                    break
                case 5:
                    self.profile5.sd_setImage(with: proRef)
                    let animation = CABasicAnimation(keyPath: "opacity")
                    animation.fromValue = 0.0
                    animation.toValue = 1.0
                    animation.duration = 0.5
                    self.profile5.layer.add(animation, forKey: "Image-opacity")
                    break
                default:
                    break
                }
            }
            labelMaxUser.text = "People: \(joinList.count+1)/\(cellData.groupSize!)"
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
