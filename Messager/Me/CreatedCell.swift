//
//  CreatedCell.swift
//  Messager
//
//  Created by Hui on 2020/10/10.
//

import Foundation
import UIKit
import Firebase
import FirebaseUI


class CreatedCell: UITableViewCell {

    @IBOutlet weak var imageLabel: UIImageView!
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    
    var activityID = ""
    
    let storage = Storage.storage()
    let db = Firestore.firestore()
    
    var cellData : ActivityData!{
    //监视器，判断是否发生变化
        didSet{
            activityLabel.text = cellData.title
            dateLabel.text = cellData.date
            self.activityID = cellData.activityID

            let imageId : String! = cellData!.image
            let cloudFileRef = storage.reference(withPath: "activity-images/"+imageId)
            self.imageLabel.sd_setImage(with: cloudFileRef)
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
