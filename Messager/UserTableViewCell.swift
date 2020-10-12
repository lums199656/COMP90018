//
//  UserTableViewCell.swift
//  Messager
//
//  Created by 陆敏慎 on 5/10/20.
//

import UIKit

class UserTableViewCell: UITableViewCell {

    
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func  configure(user: User) -> Void {
        usernameLabel.text = user.username
        statusLabel.text = user.status
        setAvatar(avatarLink: user.avatarLink)
    }
    
    private func setAvatar(avatarLink: String) {
        if avatarLink != "" {
            // 从 Firestore 下载头像，暂时还没写，先用默认头像代替
//            FileStorage.downloadImage(imageUrl: avatarLink) { (avatarImage) in
//                self.avatarImageView.image = avatarImage?.circleMasked
//            }
            self.avatarImageView.image = UIImage(named: "person.fill")
        }else{
            self.avatarImageView.image = UIImage(named: "person.fill")
        }
    }

}
