//
//  EditViewController.swift
//  Messager
//
//  Created by 王品 on 2020/10/11.
//

import UIKit
import Firebase

class EditViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    let db = Firestore.firestore()
    let storage = Storage.storage()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadInfo()

        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userLocation: UITextField!
    @IBOutlet weak var userIntro: UITextField!
    
    func loadInfo() {
        let user = Auth.auth().currentUser
        if let user = user {
            let userInfo = db.collection("UserInfo")
            let query = userInfo.whereField("userID", isEqualTo: user.uid)
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
            let queryUser = userAuth.whereField("id", isEqualTo: user.uid)
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
    
    // select image
    @IBAction func changePhoto(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = true
        
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    
    // save -> update userInfo
    @IBAction func updateUserInfo(_ sender: Any) {
        guard let image = userImage.image else { print("no image selected"); return }
        guard let id = Auth.auth().currentUser?.uid else { return }
        guard let name = userName.text else { return }
        guard let location = userLocation.text else { return }
        guard let intro = userIntro.text else {return }
        
        

        let storageRef = storage.reference()
        let infoImageRef = storageRef.child("user-photoes")
        let query = db.collection("UserInfo").whereField("userID", isEqualTo: id)
        query.getDocuments { [self] (querySnapshot, error) in
                    if let error = error {
                        print("Error getting documents: \(error)")
                    } else {
                        let docID = querySnapshot!.documents[0].documentID
                        let infoRef = db.collection("UserInfo").document(docID)
                        infoRef.setData([
                            "userID": id,
                            "userLocation": location,
                            "userIntro": intro,
                            "userImage": infoRef.documentID
                        ]) { err in
                            if let err = err {
                                print("Error adding document: \(err)")
                            } else {
                                print("Document added with ID: \(infoRef.documentID)")
                                uploadImage(from: image, to: docID)
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                    }
        }
        
        
        func uploadImage(from image: UIImage, to cloudName: String) {
            
            let cloudFileRef = infoImageRef.child(cloudName)
            
            guard let data = image.jpegData(compressionQuality: 1) else { return }  // data: image to be uploaded
            
            let uploadTask = cloudFileRef.putData(data, metadata: nil) { metadata, error in
                guard let _ = metadata else { return }  // if metadata is nil, return
                
                print("Success upload image \(cloudName)")
            }
        }
        
        // uploadInfo()
        // uploadImage(from: image, to: infoDocID)
        
        
        // Segue back to Activity View
        
    }

}
