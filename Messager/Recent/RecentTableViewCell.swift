//
//  RecentTableViewCell.swift
//  Messager
//
//  Created by 陆敏慎 on 10/10/20.
//

import UIKit
import Firebase
import FirebaseUI

class RecentTableViewCell: UITableViewCell {

    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var unreadCounterLabel: UILabel!
    @IBOutlet weak var unreadCounterBackgroundView: UIView!
    
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        unreadCounterBackgroundView.layer.cornerRadius = unreadCounterBackgroundView.frame.width / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
        
    }
    
    func configure(recent: RecentChat) {
        var tmpText = ""
    
        if !recent.isActivity {
            for i in recent.receiverName {
                tmpText += " | " + i.prefix(4)
            }
            tmpText += " | "
        } else {
            tmpText = recent.activityTitle
        }
        
        print("_x-2 聊天框标题为", tmpText)
        usernameLabel.text = tmpText
        usernameLabel.adjustsFontSizeToFitWidth = true
        usernameLabel.minimumScaleFactor = 0.9
        
        lastMessageLabel.text = recent.lastMessage
        lastMessageLabel.adjustsFontSizeToFitWidth = true
        lastMessageLabel.minimumScaleFactor = 0.9
        lastMessageLabel.numberOfLines = 2
        
        if recent.unreadCounter != 0 {
            self.unreadCounterBackgroundView.isHidden = false
            if recent.unreadCounter > 99 {
                self.unreadCounterLabel.text = "99+"
            }else{
                self.unreadCounterLabel.text = "\(recent.unreadCounter)"
            }
        }else{
            self.unreadCounterBackgroundView.isHidden = true
        }
        
        setAvatar(avatarLink: recent.avatarLink, recent: recent)

        dateLabel.text = timeElapsed(recent.date ?? Date())
        dateLabel.adjustsFontSizeToFitWidth = true
    }
    
    
    private func setAvatar(avatarLink: String, recent: RecentChat) {
        print("_x-60", avatarLink)
        if avatarLink != "" {
//             从 Firestore 下载头像，暂时还没写，先用默认头像代替
            loadImage(recent: recent)
        }else{
            self.avatarImageView.image = UIImage(named: "avatar")
        }
    }
    
    private func loadImage(recent: RecentChat) {
        if recent.isActivity {
            let docRef = db.collection(K.FStore.act).document(recent.chatRoomId)
            docRef.getDocument { [self] (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    let image = data![K.Activity.image] as! String
                    let cloudFileRef = self.storage.reference(withPath: "activity-images/"+image)
                    self.avatarImageView.sd_setImage(with: cloudFileRef)
                    self.avatarImageView.layer.cornerRadius = avatarImageView.frame.width/2
                }
            }
        } else {
            let userId = recent.receiverId[0]
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
}
