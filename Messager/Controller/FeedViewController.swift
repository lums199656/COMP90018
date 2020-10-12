//
//  FeedViewController.swift
//  Messager
//
//  Created by Boyang Zhang on 7/10/20.
//

import UIKit
import Firebase

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var lists : [FeedData] = []
    //var cur_count = 0 //用来判断当前处在哪一个位置
     
    @IBOutlet weak var tableView: UITableView!

    //显示cell个数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("list数量是")
        print(lists.count)
        return lists.count
    }
    
    //每行显示什么
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! FeedCell
        //cell.textLabel?.text = lists[indexPath.row]
        print("indexPath.row=\(indexPath.row)")
        cell.cellData = lists[indexPath.row]
        return cell
    }
    
   
    //let storage = Storage.storage()
    let db = Firestore.firestore()
    
    let dbSeed = DBSeeding(false)
    //let dbSeed = DBSeeding(true)
    
    

    
//    @IBOutlet weak var activityTitle: UILabel!
//    @IBOutlet weak var activityDetail: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("🔥FeedView Did Load")
        imageView.image = UIImage(named: "port1")
        activityDetail.sizeToFit()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("🔥FeedView Did Disappear")
    }
    
    
    // MARK:-
    
    
    @IBAction func uploadButtonPressed(_ sender: UIButton) {
        print("----------------------")
        uploadImage(from: "port1", to: "Again19")
    }
    
    @IBAction func downloadButtonPressed(_ sender: UIButton) {
        print("----------------------")
        //ImageV.image = UIImage(named: "port1")
        getData()
        print("数量是：")
        print(self.lists.count)
//        imageView.image = UIImage(named: "port1")
//        activityDetail.sizeToFit()
        
    }
    
    //调用下一个数据库数据
    func getData(){
        //获取数据
        //print("124125415")
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
                            let feedData = FeedData(detail: detail, title: title, uid: uid, user: user, image: image)
                            //print(feedData)
                            self.lists.append(feedData)
                            
                        }
                    }
                    self.tableView.reloadData()
                    //print(self.lists.count)
                }
            }
            
        }
        
    }
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
    
    @IBAction func createActivityButtonTapped(_ sender: UIButton) {
        
        
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

}


// MARK:- Activity
extension FeedViewController {
    
    
}


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
