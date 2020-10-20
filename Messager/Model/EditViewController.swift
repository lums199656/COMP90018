//
//  EditViewController.swift
//  Messager
//
//  Created by 王品 on 2020/10/11.
//

import UIKit
import Firebase

class EditViewController: UIViewController {
    let db = Firestore.firestore()
    let storage = Storage.storage()
    let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadInfo()

        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userLocation: UITextField!
    @IBOutlet weak var userIntro: UITextField!
    
    //dismiss keyboard when touch blank area
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

            self.view?.endEditing(true)

     }
    
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
    @IBAction func changePhoto(_ sender: UIButton) {
        // self.imagePicker.present(from: sender)
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
                        var infoRef = db.collection("UserInfo").document()
                        var docID = infoRef.documentID
                        if querySnapshot!.documents.count > 0 {
                            docID = querySnapshot!.documents[0].documentID
                            infoRef = db.collection("UserInfo").document(docID)
                        }
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
                                let userQuery = db.collection("User").whereField("id", isEqualTo: id)
                                userQuery.getDocuments { [self] (userQuerySnapshot, error) in
                                            if let error = error {
                                                print("Error getting documents: \(error)")
                                            } else {
                                                //
                                                let userDocID = userQuerySnapshot!.documents[0].documentID
                                                let userRef = db.collection("User").document(userDocID)
                                                userRef.updateData([
                                                    "username": name
                                                ]) { err in
                                                    if let err = err {
                                                        print("Error adding document: \(err)")
                                                    } else {
                                                        print("Document added with ID: \(userRef.documentID)")
                                                        self.navigationController?.popViewController(animated: true)
                                                    }
                                                }
                                            }
                                }
                                
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


// MARK:- Delegate for Image Picker
extension EditViewController:  UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.editedImage] as? UIImage  {
            self.userImage.image = image
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
}


extension EditViewController: UINavigationControllerDelegate {
    
}
