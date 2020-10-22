////
////  PostTableViewController.swift
////  Messager
////
////  Created by Boyang Zhang on 22/10/20.
////
//
//
import UIKit
import Firebase
import UITextView_Placeholder
import CoreLocation
//
class PostTableViewController: UITableViewController {
//
//    // post activity related data
//    var postCategory: String?
//    var postImage: UIImage?
//    var postTitle: String?
//    var postDetail: String?
//    var postLocation: CLLocation?
//    var postLocationString: String?
//
//
//    // IBOutlets
//    @IBOutlet weak var activityImageView: UIImageView!
//    @IBOutlet weak var titleTextField: UITextField!
//
//
//
//    @IBOutlet weak var detailTextView: UITextView!
//
//    @IBOutlet weak var locationLabel: UILabel!
//    @IBOutlet weak var locationButton: UIButton!
//
//    @IBOutlet weak var categoryLabel: UILabel!
//
//    // _
//    private let imagePicker = UIImagePickerController()
//    private let db = Firestore.firestore()
//    private let storage = Storage.storage()
//
//
//    // Override Function
    override func viewDidLoad() {
        super.viewDidLoad()
//
//        // Setup textView Placeholder stuff
//        detailTextView.delegate = self
//
//        detailTextView.text = "Placeholder"
//        detailTextView.textColor = UIColor.lightGray
//
////        detailTextView.becomeFirstResponder()
////        detailTextView.selectedTextRange = detailTextView.textRange(from: detailTextView.beginningOfDocument, to: detailTextView.beginningOfDocument)
//
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        self.tabBarController?.tabBar.isHidden = true
//        if let category = postCategory {
//            categoryLabel.text = "Category: " + category
//        }
//
//        setupUI()
    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//
//    }
//
//    func setupUI() {
//        locationButton.setTitle("", for: [])
//    }
//
//    // MARK:- IBActions
//
//    @IBAction func backBttnTapped(_ sender: Any) {
//        dismiss(animated: true, completion: nil)
//    }
//
//
//    @IBAction func chooseBttnTapped(_ sender: Any) {
//
//        imagePicker.delegate = self
//        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
//        imagePicker.allowsEditing = true
//
//        self.present(imagePicker, animated: true, completion: nil)
//
//    }
//
//    @IBAction func postBttnTapped(_ sender: Any) {
//        print("postBttnTapped")
//
//        guard let image = activityImageView.image else { print("no image selected"); return }
//        guard let userId = Auth.auth().currentUser?.uid else { return }
//        guard let titleText = titleTextField.text else {return }
//        guard let detailText = detailTextView.text else {return }
//
//
//        let actRef = db.collection(K.FStore.act).document()  // Activity Document reference
//        let storageRef = storage.reference()
//        let activityImageRef = storageRef.child("activity-images")
//
//        func uploadImage(from image: UIImage, to cloudName: String) {
//
//            let cloudFileRef = activityImageRef.child(cloudName)
//
//            guard let data = image.jpegData(compressionQuality: 1) else { return }  // data: image to be uploaded
//
//            let uploadTask = cloudFileRef.putData(data, metadata: nil) { metadata, error in
//                guard let _ = metadata else { return }  // if metadata is nil, return
//
//                print("Success upload image \(cloudName)")
//            }
//        }
//
//
//        func uploadActivity() {
//            let act = Activity(uid: actRef.documentID, userId: userId,
//                               createDate: Date().timeIntervalSince1970, actTitle: titleText, actDetail: detailText,
//                               imageId: actRef.documentID)
//            do {
//                try actRef.setData(from: act)
//                print("Activity Document added with ID: \(actRef.documentID)")
//            } catch let error {
//                print("Error writing city to Firestore: \(error)")
//            }
//        }
//
//        uploadActivity()
//        uploadImage(from: image, to: actRef.documentID)
//
//
//        // Segue back to Activity View
//        self.dismiss(animated: true, completion: nil)
//    }
//
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "toPost2" {
//            let destinationVC = segue.destination as! PostViewController2
//            destinationVC.postImage = self.postImage
//            destinationVC.postTitle = self.postTitle
//            destinationVC.postDetail = self.postDetail
//        }
//        if segue.identifier == "toLocation" {
//            let destinationVC = segue.destination as! PostLocationViewController
//            destinationVC.delegate = self
//        }
//
//    }
//
//
//    @IBAction func locationBttnTapped(_ sender: UIButton) {
//
//    }
//
//
}
//
//
//// MARK:- Delegate for Image Picker
//extension PostTableViewController:  UIImagePickerControllerDelegate {
//
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//
//        if let image = info[.editedImage] as? UIImage  {
//            // update image view on page
//            self.activityImageView.image = image
//
//            //
//            self.postImage = image
//        }
//
//        self.dismiss(animated: true, completion: nil)
//    }
//
//
//}
//
//// MARK:- Select Location Delegate
//extension PostTableViewController: PostLocationDelegate {
//    func updateLocation(location: CLLocation?, locString: String?) {
//        print("!!!! Update Location Called")
//
//        if let location = location, let locString = locString {
//            postLocation = location
//            postLocationString = locString
//            locationLabel.text = locString
//        } else {
//            locationLabel.text = "Any Location"
//        }
//    }
//}
//
//// MARK:- Navigation Controller Delegate
//extension PostTableViewController: UINavigationControllerDelegate {
//
//}
//
//
//// MARK:-
//extension PostTableViewController: UITextViewDelegate {
//
//
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//
//        // Combine the textView text and the replacement text to
//        // create the updated text string
//        let currentText:String = textView.text
//        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)
//
//        // If updated text view will be empty, add the placeholder
//        // and set the cursor to the beginning of the text view
//        if updatedText.isEmpty {
//
//            textView.text = "Placeholder"
//            textView.textColor = UIColor.lightGray
//
//            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
//        }
//
//        // Else if the text view's placeholder is showing and the
//        // length of the replacement string is greater than 0, set
//        // the text color to black then set its text to the
//        // replacement string
//         else if textView.textColor == UIColor.lightGray && !text.isEmpty {
//            textView.textColor = UIColor.black
//            textView.text = text
//        }
//
//        // For every other case, the text should change with the usual
//        // behavior...
//        else {
//            return true
//        }
//
//        // ...otherwise return false since the updates have already
//        // been made
//        return false
//    }
//
//    func textViewDidChangeSelection(_ textView: UITextView) {
//        if self.view.window != nil {
//            if textView.textColor == UIColor.lightGray {
//                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
//            }
//        }
//    }
//
//
//}
