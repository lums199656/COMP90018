//
//  PostDateViewController.swift
//  Messager
//
//  Created by Boyang Zhang on 22/10/20.
//

import UIKit

protocol PostDateDelegate {
//    func
}



class PostDateViewController: UIViewController {
    

    var postActStartDate: Date?
    var postActEndDate: Date?
    
    
    @IBOutlet weak var txtDatePicker: UITextField!
    
    var startDatePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        startDatePicker.datePickerMode = .dateAndTime
        startDatePicker.preferredDatePickerStyle = .wheels
        
        startDatePicker.addTarget(self, action: #selector(dateChanged(datePicker:)), for: .valueChanged)
        
        txtDatePicker.inputView = startDatePicker
        
        // tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
//        let dragUpGesture = UISwipeGestureRecognizer(target: self, action: <#T##Selector?#>)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm"
        txtDatePicker.text = dateFormatter.string(from: Date())
    }
    
    @objc func dateChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm"
        
        txtDatePicker.text = dateFormatter.string(from: datePicker.date)
    }
    
    
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    
}

