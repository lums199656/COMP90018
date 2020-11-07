//
//  ParticipantCellTableViewCell.swift
//  Messager
//
//  Created by Hui on 2020/11/7.
//

import UIKit
import Firebase
import FirebaseUI


class ParticipantCell: UITableViewCell {
    @IBOutlet var partiImage: UIImageView!
    @IBOutlet var partiName: UILabel!
    @IBOutlet var partiButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
