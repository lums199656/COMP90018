//
//  PostViewController.swift
//  Messager
//
//  Created by Boyang Zhang on 11/10/20.
//

import UIKit
import Firebase

class PostViewController: UIViewController {
    
    // IBOutlets
    @IBOutlet weak var activityImageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var detailTextView: UITextView!
    
    //
    private let imagePicker = UIImagePickerController()
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    
    // Override Function
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
    // IBActions
    @IBAction func chooseBttnTapped(_ sender: Any) {
        
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = true
        
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    
    @IBAction func postBttnTapped(_ sender: Any) {
        print("postBttnTapped")
        
        guard let image = activityImageView.image else { print("no image selected"); return }
        guard let userId = Auth.auth().currentUser?.uid else { return }
        guard let titleText = titleTextField.text else {return }
        guard let detailText = detailTextView.text else {return }
        
            
        let actRef = db.collection(K.FStore.act).document()  // Activity Document reference
        let storageRef = storage.reference()
        let activityImageRef = storageRef.child("activity-images")
        
        func uploadImage(from image: UIImage, to cloudName: String) {
            
            let cloudFileRef = activityImageRef.child(cloudName)
            
            guard let data = image.jpegData(compressionQuality: 1) else { return }  // data: image to be uploaded
            
            let uploadTask = cloudFileRef.putData(data, metadata: nil) { metadata, error in
                guard let _ = metadata else { return }  // if metadata is nil, return
                
                print("Success upload image \(cloudName)")
            }
        }
        
        func uploadActivity() {
            let act = Activity(uid: actRef.documentID, userId: userId,
                               actTitle: titleText, actDetail: detailText,
                               imageId: actRef.documentID)
            do {
                try actRef.setData(from: act)
                print("Activity Document added with ID: \(actRef.documentID)")
            } catch let error {
                print("Error writing city to Firestore: \(error)")
            }
        }
        
        uploadActivity()
        uploadImage(from: image, to: actRef.documentID)
        
        
        // Segue back to Activity View
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
}


// MARK:- Delegate for Image Picker
extension PostViewController:  UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.editedImage] as? UIImage  {
            self.activityImageView.image = image
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
}


extension PostViewController: UINavigationControllerDelegate {
    
}
