//
//  PostViewController.swift
//  Messager
//
//  Created by Boyang Zhang on 11/10/20.
//

import UIKit
import Firebase
import UITextView_Placeholder
import CoreLocation
import IQKeyboardManagerSwift


class PostViewController1: UIViewController {
    
    // post activity related data
    var postCategory: String?
    var postImage: UIImage?
    var postTitle: String?
    var postDetail: String?
    var postLocation: CLLocation?
    var postLocationString: String?
    var postActStartDate: Date?
    var postActEndDate: Date?
    
    
    // IBOutlets
    @IBOutlet weak var activityImageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var detailTextView: UITextView!
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationButton: UIButton!
    
    @IBOutlet weak var categoryLabel: UILabel!
    
    
    @IBOutlet weak var startDateField: UITextField!
    @IBOutlet weak var endDateField: UITextField!
    
    
    // _
    private let imagePicker = UIImagePickerController()
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    var startDatePicker = UIDatePicker()
    var endDatePicker = UIDatePicker()

    // MARK:- View Lifecycle
    // Override Function
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup textView Placeholder stuff
        detailTextView.delegate = self
        
        detailTextView.text = "Activity Details here..."
        detailTextView.textColor = UIColor.lightGray
        
        
        // Date Pickers
        startDatePicker.datePickerMode = .dateAndTime
        startDatePicker.preferredDatePickerStyle = .wheels
        endDatePicker.datePickerMode = .dateAndTime
        endDatePicker.preferredDatePickerStyle = .wheels
        
        // _. change input view of textfiled
        startDateField.inputView = startDatePicker
        endDateField.inputView = endDatePicker
        
        startDatePicker.addTarget(self, action: #selector(startDateChanged(datePicker:)), for: .valueChanged)
        endDatePicker.addTarget(self, action: #selector(endDateChanged(datePicker:)), for: .valueChanged)
        
        // __. init Start time and show on screen
        var nowDate = Date().advanced(by: 60*60*3)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM yyyy HH:00"
        startDateField.text = dateFormatter.string(from: nowDate)
        postActStartDate = nowDate
        
        nowDate = nowDate.advanced(by: 60*60)
        endDateField.text = dateFormatter.string(from: nowDate)
        postActEndDate = nowDate
        
        startDatePicker.minimumDate = Date()
        endDatePicker.minimumDate = nowDate.advanced(by: -60*60)
        
        startDatePicker.minuteInterval = 15
        endDatePicker.minuteInterval = 15
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        if let category = postCategory {
            categoryLabel.text = category
        }
        
        setupUI()
        
        IQKeyboardManager.shared.enable = true  // for
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = false
    }
    
    // MARK:-
    @objc func startDateChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm"
        
        startDateField.text = dateFormatter.string(from: datePicker.date)
        
        // limit startPicker range
        endDatePicker.minimumDate = startDatePicker.date.advanced(by: 60*15)
        postActStartDate = datePicker.date
        
        // TODO: 如果start date > end date， 自动更新end date
    }
    
    @objc func endDateChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm"
        
        endDateField.text = dateFormatter.string(from: datePicker.date)
        
        postActEndDate = datePicker.date
    }
    
    
    
    
    func setupUI() {
        locationButton.setTitle("", for: [])
    }
    
    // MARK:- IBActions
    
    @IBAction func backBttnTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func chooseBttnTapped(_ sender: Any) {
        
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = true
        
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    
    @IBAction func postBttnTapped(_ sender: Any) {

        
        guard let image = activityImageView.image else { print("no image selected"); return }
        guard let userId = Auth.auth().currentUser?.uid else { return }
        guard let titleText = titleTextField.text else {return }
        guard let detailText = detailTextView.text else {return }
        
            
        let actRef = db.collection(K.FStore.act).document()  // new Activity Document reference
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

            var geoPoint: GeoPoint?
            if let location = postLocation {
                geoPoint = GeoPoint.init(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            }
            let readDic = [userId: 1]
            actRef.setData([
                "actDetail": detailText,
                "actTitle": titleText,
                "createDate": Date() as Any,
                "startDate": postActStartDate as Any,
                "endDate": postActEndDate as Any,
                "location": geoPoint as Any,
                "locationString": postLocationString as Any,
                "category": postCategory as Any,
                "imageId": actRef.documentID,
                "read_dic": readDic as Any
            ])

            print("Activity Document added with ID: \(actRef.documentID)")
        }
        
        uploadActivity()
        uploadImage(from: image, to: actRef.documentID)
        
        
        // Segue back to Activity View
        self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
        self.dismiss(animated: true, completion: nil)
        

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "toLocation" {
            let destinationVC = segue.destination as! PostLocationViewController
            destinationVC.delegate = self
        }
        
    }
    
    
    @IBAction func locationBttnTapped(_ sender: UIButton) {
        
    }
    
    
}


// MARK:- Delegate for Image Picker
extension PostViewController1:  UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.editedImage] as? UIImage  {
            // update image view on page
            self.activityImageView.image = image
            
            //
            self.postImage = image
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

// MARK:- Select Location Delegate
extension PostViewController1: PostLocationDelegate {
    func updateLocation(location: CLLocation?, locString: String?) {
        print("!!!! Update Location Called")
        
        if let location = location, let locString = locString {
            postLocation = location
            postLocationString = locString
            locationLabel.text = locString
        } else {
            locationLabel.text = "Any Location"
        }
    }
}

// MARK:- Navigation Controller Delegate
extension PostViewController1: UINavigationControllerDelegate {
    
}


// MARK:-
extension PostViewController1: UITextViewDelegate {
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        // Combine the textView text and the replacement text to
        // create the updated text string
        let currentText:String = textView.text
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)

        // If updated text view will be empty, add the placeholder
        // and set the cursor to the beginning of the text view
        if updatedText.isEmpty {

            textView.text = "Activity Details here..."
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
