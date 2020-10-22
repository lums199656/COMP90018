//
//  ActivityDetailController.swift
//  Messager
//
//  Created by 王品 on 2020/10/22.
//

import UIKit
import Firebase

class ActivityDetailController: UIViewController {
    var activityID = ""
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        print(activityID)
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var activityTitle: UILabel!
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
    
    
    func loadData() {
        let query = db.collection(K.FStore.act).whereField("uid", isEqualTo: activityID)
        query.getDocuments { [self] (querySnapshot, error) in
            if let e = error{
                print("error happens in getDocuments\(e)" )
            }
            else{
                let doc = querySnapshot!.documents[0]
                let data = doc.data()
                activityTitle.text = data[K.Activity.title] as? String
                let image = data[K.Activity.image] as! String
                // read date later
                date.text = ""
                let starterId = data["userId"] as? String
                details.text = data["actDetail"] as? String
                
                let userInfo = db.collection("User")
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
                                                cloudFileRef.getData(maxSize: 1*1024*1024) { (data, error) in
                                                    if let error = error {
                                                        print(error.localizedDescription)
                                                    } else {
                                                        self.starterImage.image = UIImage(data: data!)
                                                    }
                                                }

                            }
                        }
                }

                
                let cloudFileRef = self.storage.reference(withPath: "activity-images/"+image)
                            cloudFileRef.getData(maxSize: 1*1024*1024) { (data, error) in
                                if let error = error {
                                    print(error.localizedDescription)
                                } else {
                                    self.image.image = UIImage(data: data!)
                                }
                            }

                        
            }

        }
    }
}
