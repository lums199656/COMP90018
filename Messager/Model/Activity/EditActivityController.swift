//
//  EditActivityController.swift
//  Messager
//
//  Created by 王品 on 2020/10/25.
//

import UIKit
import Firebase
import UITextView_Placeholder


class EditActivityController: UIViewController {

    // post activity related data
    var activityID: String = ""
    var category: String = ""
    var image: UIImage?
    var titleAct: String = ""
    var detail: String = ""
    var location: String = ""

    
    // IBOutlets
    @IBOutlet weak var activityImageView: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationButton: UIButton!
    
    
    // _
    private let imagePicker = UIImagePickerController()
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    
    // Override Function
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup textView Placeholder stuff
        detailTextView.delegate = self
        detailTextView.text = detail
        detailTextView.textColor = UIColor.lightGray
        locationLabel.text = location
        activityImageView.image = image
        titleTextField.text = titleAct
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        categoryLabel.text = "Category: " + category
        
        setupUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    
    }
    
    func setupUI() {
        locationButton.setTitle("", for: [])
    }
    
    // MARK:- IBActions
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
        
    @IBAction func chooseImage(_ sender: Any) {
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = true
        
        self.present(imagePicker, animated: true, completion: nil)

    }
    
    @IBAction func save(_ sender: Any) {
        guard let image = activityImageView.image else { print("no image selected"); return }
        guard let userId = Auth.auth().currentUser?.uid else { return }
        guard let titleText = titleTextField.text else {return }
        guard let detailText = detailTextView.text else {return }
        
            
        let actRef = db.collection(K.FStore.act).document(activityID)  // Activity Document reference
        let storageRef = storage.reference()
        let activityImageRef = storageRef.child("activity-images")
        
        func uploadImage(from image: UIImage, to cloudName: String) {
            
            let cloudFileRef = activityImageRef.child(cloudName)
            
            guard let data = image.jpegData(compressionQuality: 1) else { return }
            let uploadTask = cloudFileRef.putData(data, metadata: nil) { metadata, error in
                guard let _ = metadata else { return }  // if metadata is nil, return
                
                print("Success upload image \(cloudName)")
            }
        }
        
        
        func uploadActivity() {
            let act = Activity(uid: actRef.documentID, userId: userId,
                               createDate: Date().timeIntervalSince1970, actTitle: titleText, actDetail: detailText,
                               imageId: actRef.documentID)
            do {
                try actRef.updateData([
                    "actTitle": titleTextField.text,
                    "actDetail": detailTextView.text,
                    "locationString": locationLabel.text
                ])
                print("Activity Document added with ID: \(actRef.documentID)")
            } catch let error {
                print("Error writing city to Firestore: \(error)")
            }
        }
        
        uploadActivity()
        uploadImage(from: image, to: actRef.documentID)
        
        
        // Segue back to Activity View
        self.dismiss(animated: true, completion: nil)
    }
    
    
}


// MARK:- Delegate for Image Picker
extension EditActivityController:  UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.editedImage] as? UIImage  {
            // update image view on page
            self.activityImageView.image = image
            
            //
            self.image = image
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

// MARK:- Select Location Delegate
extension EditActivityController: SelectLocationDelegate {
    func updateLocation(_ locString: String) {
        print("!!!! Update Location Called")
        
        location = locString
        
        locationLabel.text = locString
        
    }
}

// MARK:- Navigation Controller Delegate
extension EditActivityController: UINavigationControllerDelegate {
    
}


// MARK:-
extension EditActivityController: UITextViewDelegate {
    

    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        // Combine the textView text and the replacement text to
        // create the updated text string
        let currentText:String = textView.text
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)

        // If updated text view will be empty, add the placeholder
        // and set the cursor to the beginning of the text view
        if updatedText.isEmpty {

            textView.text = "Placeholder"
            textView.textColor = UIColor.lightGray

            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        }

        // Else if the text view's placeholder is showing and the
        // length of the replacement string is greater than 0, set
        // the text color to black then set its text to the
        // replacement string
         else if textView.textColor == UIColor.lightGray && !text.isEmpty {
            textView.textColor = UIColor.black
            textView.text = text
        }

        // For every other case, the text should change with the usual
        // behavior...
        else {
            return true
        }

        // ...otherwise return false since the updates have already
        // been made
        return false
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor == UIColor.lightGray {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
        }
    }
    
    
}
