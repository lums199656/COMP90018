//
//  UserTableViewCell.swift
//  Messager
//
//  Created by 陆敏慎 on 5/10/20.
//

import UIKit
import Firebase
import FirebaseUI

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(user: User) -> Void {
        usernameLabel.text = user.username
        statusLabel.text = user.status
        setAvatar(avatarLink: user.avatarLink, userId: user.id)
    }
    
    private func setAvatar(avatarLink: String, userId: String) {
        print("_x-45 头像链接是", avatarLink)
        if avatarLink != "" {
            print("_x-46")
//             从 Firestore 下载头像，暂时还没写，先用默认头像代替
//            FileStorage.downloadImage(imageUrl:  "user-photoes/"+avatarLink) { (avatarImage) in
//                print("_x-48", avatarImage)
//                self.avatarImageView.image = avatarImage
//            }
//            self.avatarImageView.image = UIImage(named: "avatar")
            loadImage(userId: userId)
            
        }else{
            print("_x-47")
            self.avatarImageView.image = UIImage(named: "avatar")
        }
    }
    
    private func loadImage(userId: String) {

        let userInfo = db.collection("User")
        let query = userInfo.whereField("id", isEqualTo: userId)
        query.getDocuments { [self] (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let image = data["avatarLink"] as! String
                    let cloudFileRef = self.storage.reference(withPath: "user-photoes/"+image)
                    self.avatarImageView.sd_setImage(with: cloudFileRef)
                    self.avatarImageView.layer.cornerRadius = avatarImageView.frame.width/2

                }
            }
        }

    }
}
