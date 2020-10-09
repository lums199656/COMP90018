//
//  FeedCell.swift
//  Messager
//
//  Created by zhangchongjing on 2020/10/9.
//

import UIKit

class FeedCell: UITableViewCell {

    
    @IBOutlet weak var labelD: UILabel!
    @IBOutlet weak var labelT: UILabel!
    
        var cellData : FeedData!{
        //监视器，判断是否发生变化
        didSet{
            labelT.text = cellData.title
            labelD.text = cellData.detail
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
