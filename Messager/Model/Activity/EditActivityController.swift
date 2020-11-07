//
//  EditActivityController.swift
//  Messager
//
//  Created by 王品 on 2020/10/25.
//

import UIKit
import Firebase
import UITextView_Placeholder
import CoreLocation
import IQKeyboardManagerSwift
import FirebaseFirestore


class EditActivityController: UIViewController {
    
    // Pop Up View
    var popup: UIView!

    // post activity related data
    var activityID: String = ""
    var category: String = ""
    var image: UIImage?
    var titleAct: String = ""
    var detail: String = ""
    var locationStr: String = ""
    var coord: CLLocation?
    var startDate: Date?
    var endDate: Date?
    
    var oldFileRef: StorageReference?

    
    // IBOutlets
    @IBOutlet weak var activityImageView: UIImageView! {
        didSet {
            activityImageView.contentMode = .scaleAspectFill
        }
    }
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var startDateField: UITextField!
    @IBOutlet weak var endDateField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    
    // _
    private let imagePicker = UIImagePickerController()
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    var startDatePicker = UIDatePicker()
    var endDatePicker = UIDatePicker()
    
    var postActStartDate: Date?
    var postActEndDate: Date?

    // Override Function
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup textView Placeholder stuff
        detailTextView.delegate = self
        detailTextView.text = detail
        // detailTextView.textColor = UIColor.lightGray
        locationLabel.text = locationStr
        activityImageView.image = image
        titleTextField.text = titleAct
        categoryLabel.text = category
        startDateField.text = ""
        endDateField.text = ""
        
        startDatePicker.datePickerMode = .dateAndTime
        startDatePicker.preferredDatePickerStyle = .wheels
        endDatePicker.datePickerMode = .dateAndTime
        endDatePicker.preferredDatePickerStyle = .wheels
        
        // _. change input view of textfiled
        startDateField.inputView = startDatePicker
        endDateField.inputView = endDatePicker
        
        startDatePicker.addTarget(self, action: #selector(startDateChanged(datePicker:)), for: .valueChanged)
        endDatePicker.addTarget(self, action: #selector(endDateChanged(datePicker:)), for: .valueChanged)
        
        startDatePicker.minuteInterval = 15
        endDatePicker.minuteInterval = 15
        
        // __. Set minimum Date for DatePicker()
        var nowDate = Date()
        startDatePicker.minimumDate = nowDate
        endDatePicker.minimumDate = nowDate.advanced(by: 60*15)
        
        // __. Init Start/End time and show on screen
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm"
        
//        nowDate = Date().nearestHour().advanced(by: 60*60*2)
        
        startDateField.text = dateFormatter.string(from: startDate!)
        postActStartDate = startDate
        
        nowDate = nowDate.advanced(by: 60*60)
        endDateField.text = dateFormatter.string(from: endDate!)
        postActEndDate = endDate

    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        categoryLabel.text = category
        
        setupUI()
        
        IQKeyboardManager.shared.enable = true  // for
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = false
    }
    
    func setupUI() {
        locationButton.setTitle("", for: [])
        
    }

    // MARK:- Date Picker
    @objc func startDateChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm"
        
        startDateField.text = dateFormatter.string(from: datePicker.date)
        
        
        // Auto Update End Date if Start > End
        if datePicker.date > endDatePicker.date {
            endDatePicker.date = datePicker.date.advanced(by: 60*15)
            endDateField.text = dateFormatter.string(from: endDatePicker.date)
        }
        
        // limit startPicker range
        endDatePicker.minimumDate = startDatePicker.date.advanced(by: 60*15)
        postActStartDate = datePicker.date
        
    }
    
    @objc func endDateChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm"
        
        endDateField.text = dateFormatter.string(from: datePicker.date)
        
        postActEndDate = datePicker.date
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
        guard let image = activityImageView.image else {
            self.showAlert("No image selected")
            return
        }
        guard let userId = Auth.auth().currentUser?.uid else { return }
        guard let titleText = titleTextField.text else {return }
        guard titleText.count > 5 else {
            print("Title needs to be longer than 5")
            self.showAlert("Title needs to be more than 5 characters")
            return
        }
        guard let detailText = detailTextView.text else {return }
        guard detailText.count > 30 else {
            print("Detail needs to be longer than 30")
            self.showAlert("Detail needs to be more than 30 characters")
            return
        }
        
        

            
        let actRef = db.collection(K.FStore.act).document(activityID)  // Activity Document reference
        let storageRef = storage.reference()
        let activityImageRef = storageRef.child("activity-images")
        
        func uploadImage(from image: UIImage, to cloudName: String, completion:@escaping(() -> () )) {
            let cloudFileRef = activityImageRef.child(cloudName)
            guard let data = image.jpegData(compressionQuality: 1) else {completion() ;return }
        
            let uploadTask = cloudFileRef.putData(data, metadata: nil) { metadata, error in
                guard let _ = metadata else {return }
                completion()
            }
        }

        let imageID = actRef.documentID + String(format: "%d", Int(NSDate().timeIntervalSince1970*100000))

        func uploadActivity() {
            var geoPoint: GeoPoint?
            if let location = coord {
                geoPoint = GeoPoint.init(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            }
            print(titleTextField.text)
            print(detailTextView.text)
            print(postActStartDate)
            print(postActEndDate)
            print(geoPoint)
            print(locationLabel.text)
            print(imageID)
            do {
                try actRef.updateData([
                    "actTitle": titleTextField.text,
                    "actDetail": detailTextView.text,
                    "startDate": postActStartDate as Any,
                    "endDate": postActEndDate as Any,
                    "location": geoPoint as Any,
                    "locationString": locationLabel.text,
                    "imageId": imageID
                ])
                print("Activity Document added with ID: \(actRef.documentID)")
            } catch let error {
                print("Error writing city to Firestore: \(error)")
            }
        }
        
//        self.showSavingAlert("Saving...")
        self.showDino()
        
        uploadActivity()
        uploadImage(from: image, to: imageID, completion: { () in
            // Segue back to Activity View
            self.oldFileRef?.delete()
            self.dismissAlert()
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    

    @IBAction func locationBttnTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let locationVC = storyboard.instantiateViewController(withIdentifier: "locationVC") as? PostLocationViewController else {  return }
        
        locationVC.delegate = self
        
        self.present(locationVC, animated: true, completion: nil)
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
extension EditActivityController: PostLocationDelegate {
    func updateLocation(location: CLLocation?, locString: String?) {
        print("!!!! Update Location Called")
        
        if let location = location, let locString = locString {
            coord = location
            locationStr = locString
            locationLabel.text = locString
        } else {
            locationLabel.text = "Any Location"
        }
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


// MARK:-
extension EditActivityController {
    func showAlert(_ alertText: String) {
        saveButton.isEnabled = false
        
        popup = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 150))
        popup.cornerRadius = 10
        
        let popIcon = UIImageView(frame: CGRect(x: 50, y: 20, width: 100, height: 100))
        popIcon.image = UIImage(named: "ic_close_48px")
        popIcon.alpha = 0.8
        
        let popLabel = UILabel(frame: CGRect(x: 10, y: 90, width: 180, height: 100))
        popLabel.numberOfLines = 0
        popLabel.text = alertText
        popLabel.font = UIFont(name: "Futura", size: 15)
        popLabel.textAlignment = .center
        popLabel.center = popup.center
        popup.addSubview(popLabel)
        
        popup.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        popup.center = view.center

        popup.layer.shadowColor = UIColor.black.cgColor
        popup.layer.shadowOpacity = 1
        popup.layer.shadowOffset = .zero
        popup.layer.shadowRadius = 200
        
        self.view.addSubview(popup)
        
        Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(dismissAlert), userInfo: nil, repeats: false)
        
    }
    
    func showSavingAlert(_ alertText: String) {
        saveButton.isEnabled = false
        
        popup = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 150))
        popup.cornerRadius = 10
        
        let popIcon = UIImageView(frame: CGRect(x: 50, y: 20, width: 100, height: 100))
        popIcon.image = UIImage(named: "ic_close_48px")
        popIcon.alpha = 0.8
//        popup.addSubview(popIcon)
        
        let popLabel = UILabel(frame: CGRect(x: 10, y: 90, width: 180, height: 100))
        popLabel.numberOfLines = 0
        popLabel.text = alertText
        popLabel.font = UIFont(name: "Futura", size: 15)
        popLabel.textAlignment = .center
        popLabel.center = popup.center
        popup.addSubview(popLabel)
        
        popup.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        popup.center = view.center

        popup.layer.shadowColor = UIColor.black.cgColor
        popup.layer.shadowOpacity = 1
        popup.layer.shadowOffset = .zero
        popup.layer.shadowRadius = 200
        
        self.view.addSubview(popup)
    }
    
    func showDino() {
        saveButton.isEnabled = false
        
        popup = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 150))
        popup.cornerRadius = 10
        
        let popIcon = UIImageView(frame: CGRect(x: 50, y: 20, width: 100, height: 100))
        popIcon.image = UIImage(named: "dino3")
        popup.addSubview(popIcon)
        
        var gif_index = 1
        
        popup.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        popup.center = view.center
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (timer) in
            popIcon.image = UIImage(named: "dino\(gif_index)")
            gif_index += 1
            if gif_index > 3 {
                gif_index = 1
            }
        }
        
        self.view.addSubview(popup)
        

    }
    
//    @objc func animate() {
//
//        popIcon.image = UIImage(named: "dino\(gif_index)")
//        gif_index += 1
//        if gif_index > 3 {
//            gif_index = 1
//        }
//    }
    
    @objc func dismissAlert() {
        saveButton.isEnabled = true

        if popup != nil {
            popup.removeFromSuperview()
        }
    }
}

