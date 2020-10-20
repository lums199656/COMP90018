//
//  FeedViewController.swift
//  Messager
//
//  Created by Boyang Zhang on 7/10/20.
//

import UIKit
import Firebase
import Lottie
import DOFavoriteButtonNew

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var lists : [FeedData] = []
    //var cur_count = 0 //用来判断当前处在哪一个位置
     
    @IBOutlet weak var tableView: UITableView!

    //显示cell个数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("list数量是"+lists.count)
        return lists.count
    }
    
    //每行显示什么
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! FeedCell
        //cell.textLabel?.text = lists[indexPath.row]
        print("indexPath.row=\(indexPath.row)")
        cell.cellData = lists[indexPath.row]
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
   
    //let storage = Storage.storage()
    let db = Firestore.firestore()
    
    let dbSeed = DBSeeding(false)
    //let dbSeed = DBSeeding(true)
    
    //控制cell行高
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        print(UIScreen.main.bounds.size.height)
        return UIScreen.main.bounds.size.height - 80
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("🔥FeedView Did Load")
        let button = DOFavoriteButtonNew(frame: CGRect(x: 100, y:100, width: 44, height: 44), image: UIImage(named: "heart.png"))
        self.view.addSubview(button)
        button.addTarget(self, action: #selector(tapped(sender:)), for: UIControl.Event.touchUpInside)
        
        getData()
        
    }
    @objc func tapped(sender: DOFavoriteButtonNew) {
            if sender.isSelected {
                // deselect
                sender.deselect()
            } else {
                // select with animation
                sender.select()
            }
        }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("🔥FeedView Did Disappear")
    }
    
  
    //调用下一个数据库数据
    func getData(){
        //获取数据
        db.collection(K.FStore.act).getDocuments{ (querySnapshot, error) in
            if let e = error{
                print("error happens in getDocuments\(e)" )
            }
            else{
                if let snapShotDocuments = querySnapshot?.documents{
                    for doc in snapShotDocuments{
                        let data = doc.data()
                        //将数据赋值建立结构体，加入到lists中
                        if let detail = data[K.Activity.detail] as? String, let title = data[K.Activity.title] as? String, let uid = data[K.Activity.uid] as? String, let user = data[K.Activity.user] as? String, let image = data[K.Activity.image] as? String{
                            //print(detail)
                            var user1: String = ""
                            var user2: String = ""
                            var user3: String = ""
                            var user4: String = ""
                            var user5: String = ""
                            //通过uid找到join表，获取userID
                            self.db.collection("JoinUsers").whereField("keyID", isEqualTo: uid).getDocuments{ (querySnapshot, error) in
                                if let e = error{
                                    print("error happens in getDocuments\(e)" )
                                }
                                else{
                                    if let snapShotDocuments = querySnapshot?.documents{
                                        for doc in snapShotDocuments{
                                            let data = doc.data()
                                            if(data["user1"] != nil){
                                                user1 = data["user1"] as! String
                                            }
                                            if(data["user2"] != nil){
                                                user2 = data["user2"] as! String
                                            }
//                                            if(data["user3"] != nil){
//                                                user3 = data["user3"] as! String
//                                            }
//                                            if(data["user4"] != nil){
//                                                user4 = data["user4"] as! String
//                                            }
//                                            if(data["user5"] != nil){
//                                                user5 = data["user5"] as! String
//                                            }
                                            
                                            
//                                            self.db.collection("JoinUsers").whereField("keyID", isEqualTo: uid).getDocuments{ (querySnapshot, error) in
//                                                if let e = error{
//                                                    print("error happens in getDocuments\(e)" )
//                                                }
//                                                else{
//                                                    if let snapShotDocuments = querySnapshot?.documents{
//                                                        for doc in snapShotDocuments{
//                                                            let data = doc.data()
//                                                        }
//                                                    }
//                                                }
//                                            }
                                            //通过userID获取 userImage
                                            self.db.collection("UserInfo").whereField("userID", isEqualTo: user1).getDocuments{ (querySnapshot, error) in
                                                if let e = error{
                                                    print("error happens in getDocuments\(e)" )
                                                }
                                                else{
                                                    if let snapShotDocuments = querySnapshot?.documents{
                                                        for doc in snapShotDocuments{
                                                            let data = doc.data()
                                                            if let user1_1 = data["userImage"] as? String{
                                                                user1 = user1_1
                                                            }
                                                        }
                                                    }
                                                }
                                                self.db.collection("UserInfo").whereField("userID", isEqualTo: user2).getDocuments{ (querySnapshot, error) in
                                                    if let e = error{
                                                        print("error happens in getDocuments\(e)" )
                                                    }
                                                    else{
                                                        if let snapShotDocuments = querySnapshot?.documents{
                                                            for doc in snapShotDocuments{
                                                                let data = doc.data()
                                                                if let user2_2 = data["userImage"] as? String{
                                                                    user2 = user2_2
                                                                }
                                                            }
                                                        }
                                                    }
                                                    let feedData = FeedData(detail: detail, title: title, uid: uid, user: user, image: image, user1: user1, user2: user2)
                                                    //print(feedData)
                                                    self.lists.append(feedData)
                                                    self.tableView.reloadData()
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
            
    }
    
//    func findProfile(name: String) -> String{
//        var pic : String = ""
//        db.collection("UserInfo").whereField("userID", isEqualTo: name).getDocuments{ (querySnapshot, error) in
//            if let e = error{
//                print("step2")
//                print("error happens in getDocuments\(e)" )
//            }
//            else{
//                if let snapShotDocuments = querySnapshot?.documents{
//                    for doc in snapShotDocuments{
//                        let data = doc.data()
//                        //将数据赋值建立结构体，加入到lists中
//                        pic = data["userImage"] as! String
//                        print("pic is:"+pic)
//                    }
//                }
//            }
//        }
//        print("pic is"+pic)
//        return pic
//    }

    //下滑拖动结束时候会触发事件的方法
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //self.tableView.reloadData()
    }
    
    
//    @IBAction func uploadButtonPressed(_ sender: UIButton) {
//        print("----------------------")
//        uploadImage(from: "port1", to: "Again19")
//    }
//
//    @IBAction func downloadButtonPressed(_ sender: UIButton) {
//        print("----------------------")
//
//        downloadImage("port4")
//    }
//
//    @IBAction func upTextButtonPressed(_ sender: UIButton) {
//        let title = "尴尬不尴尬"
//        let detail = "Wonderland Lalaland Give me five"
        
        // Method 1: Add new doc to collection, auto-generate id
//        var ref: DocumentReference? = nil
//        ref = db.collection("activities").addDocument(data: [
//            "title": title,
//            "detail": detail
//        ]) { error in
//            if let e = error {
//                print("Error saving data to firestore, \(e)")
//            } else {
//                print("Document added with ID: \(ref!.documentID)")
//            }
//        }
//
        // Method 2: set data of a document, explicitly set id
//        let docRef = db.collection("activities").document("explicitSpecified")
//        docRef.setData([
//            "title": title,
//            "detail": detail
//        ]) { err in
//            if let err = err {
//                print("Error writing document: \(err)")
//            } else {
//                print("Document successfully written!")
//            }
//        }
//
//    }
    
func createActivityButtonTapped(_ sender: UIButton) {
        
        
    }
    
    
    
//    @IBAction func downTextButtonPressed(_ sender: UIButton) {
//        db.collection("activities").getDocuments { (querySnapshot, error) in
//            if let e = error {
//                print("Error getting documents: \(e)")
//            } else {
//                for document in querySnapshot!.documents {
//                    print("\(document.documentID) => \(document.data())")
//                }
//            }
//        }
        
//        let docRef = db.collection("activities").document("explicitSpecified")
//        docRef.getDocument { (docSnapShot, error) in
//            guard let docSnapShot = docSnapShot, docSnapShot.exists else {return}
//            let data = docSnapShot.data()
//            let title = data?["title"] as? String ?? ""
//            let detail = data?["detail"] as? String ?? ""
//            self.activityDetail.text = detail
//            self.activityTitle.text = title
//        }
//
//
//    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */




//// MARK:- Activity
//extension FeedViewController {
//
//
//}


// MARK:- Image

//extension FeedViewController {
//
//    /// Upload the image from memory to Cloud
//    ///
//    /// - warning:
//    /// - parameter fileName:
//    /// - parameter cloudName: use `activityApplicationId` for file reference
//    /// - returns: string representation of the poo
//    func uploadImage(from fileName: String, to cloudName: String) {
//        // 1. Cloud Storage Reference
//        let storageRef = storage.reference()
//        let activityImageRef = storageRef.child("activity-images")
//        let cloudFileRef = activityImageRef.child(cloudName)
//        print(cloudFileRef)
//
//        // 2. Convert image to Data()
//        guard let data = UIImage(named: fileName)?.jpegData(compressionQuality: 1) else {
//            fatalError("")
//        }
//
//        // 3. Upload the file to the path "activity-images/_"
//        let uploadTask = cloudFileRef.putData(data, metadata: nil) { (metadata, error) in
//            guard let metadata = metadata else {
//                fatalError("metadata error?")
//            }
//
//            // Metadata contains file metadata such as size, content-type.
//            let size = metadata.size
//            print(size)
//
//            // You can also access to download URL after upload.
//            cloudFileRef.downloadURL { (url, error) in
//                guard let downloadURL = url else {
//                    // Uh-oh, an error occurred!
//                    return
//                }
//            }
//        }
//    }
//
//
//
//    /// Download the image from Cloud
//    ///
//    ///- parameter cloudName: use `activityApplicationId` for file reference
//    /// - returns: UIImage?
//    /// - warning: return `nil` when error occur
//    func downloadImage(_ cloudName: String){
//
//        // 1. Create a reference with an initial file path and name
//        let cloudFileRef = storage.reference(withPath: "activity-images/\(cloudName)")
//        print(cloudFileRef)
//
//        cloudFileRef.getData(maxSize: 1*1024*1024) { (data, error) in
//            if let error = error {
//                print(error.localizedDescription)
//            } else {
//                self.imageView.image = UIImage(data: data!)
//
//            }
//        }
//    }
//
    
//    func uploadImage() { // from local
//        let uploadTask = cloudFileRef.putFile(from: localFile, metadata: nil) {
//            metadata, error in
//
//            guard let metadata = metadata else {
//                return
//                print(error)
//            }
//
//            let size = metadata.size
//
//            cloudFileRef.downloadURL { (url, error) in
//                guard let downloadURL = url else {
//                    return
//                }
//            }
//
//        }
//    }
//}
}
