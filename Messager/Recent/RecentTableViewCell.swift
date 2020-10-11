//
//  RecentTableViewCell.swift
//  Messager
//
//  Created by 陆敏慎 on 10/10/20.
//

import UIKit

class RecentTableViewCell: UITableViewCell {

    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var unreadCounterLabel: UILabel!
    @IBOutlet weak var unreadCounterBackgroundView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        unreadCounterBackgroundView.layer.cornerRadius = unreadCounterBackgroundView.frame.width / 2
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
        
    }
    
    func configure(recent: RecentChat) {
        usernameLabel.text = recent.receiverName
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
        
        setAvatar(avatarLink: recent.avatarLink)

        dateLabel.text = timeElapsed(recent.date ?? Date())
        dateLabel.adjustsFontSizeToFitWidth = true
    }
    
    
    private func setAvatar(avatarLink: String) {
        if avatarLink != "" {
            // 从 Firestore 下载头像，暂时还没写，先用默认头像代替
//            FileStorage.downloadImage(imageUrl: avatarLink) { (avatarImage) in
//                self.avatarImageView.image = avatarImage
//            }
            self.avatarImageView.image = UIImage(named: "avatar")
        }else{
            self.avatarImageView.image = UIImage(named: "avatar")
        }
    }

}
