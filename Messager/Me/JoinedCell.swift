//
//  JoinedCell.swift
//  Messager
//
//  Created by Hui on 2020/10/10.
//

import Foundation
import UIKit
import Firebase
import FirebaseUI


class JoinedCell: UITableViewCell {
    @IBOutlet var joinedImage: UIImageView!
    @IBOutlet var joinedActivity: UILabel!
    @IBOutlet var joinedDate: UILabel!
    
    
    var activityID = ""
    
    let storage = Storage.storage()
    let db = Firestore.firestore()
    
    var cellData : ActivityData!{
    //监视器，判断是否发生变化
        didSet{
            joinedActivity.text = cellData.title
            joinedDate.text = cellData.date
            self.activityID = cellData.activityID

            let imageId : String! = cellData!.image
            let cloudFileRef = storage.reference(withPath: "activity-images/"+imageId)
            print("activity-images/"+imageId)
            self.joinedImage.sd_setImage(with: cloudFileRef)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
