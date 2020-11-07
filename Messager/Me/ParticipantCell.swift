//
//  ParticipantCellTableViewCell.swift
//  Messager
//
//  Created by Hui on 2020/11/7.
//
import Foundation
import UIKit
import Firebase
import FirebaseUI


class ParticipantCell: UITableViewCell {
    @IBOutlet var partiImage: UIImageView?
    @IBOutlet var partiName: UILabel?
    var userID = ""
    
    let storage = Storage.storage()
    let db = Firestore.firestore()
    
    var cellData = User(){
    //监视器，判断是否发生变化
        didSet{
            partiName?.text = cellData.username
            self.userID = cellData.id
 
            let cloudFileRef = self.storage.reference(withPath: "user-photoes/"+cellData.avatarLink)
            self.partiImage?.sd_setImage(with: cloudFileRef)
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
