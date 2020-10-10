//
//  FeedCell.swift
//  Messager
//
//  Created by zhangchongjing on 2020/10/9.
//

import UIKit
import Firebase

class FeedCell: UITableViewCell {

    
    @IBOutlet weak var labelD: UILabel!
    @IBOutlet weak var labelT: UILabel!
    @IBOutlet weak var feedImage: UIImageView!
    
    let storage = Storage.storage()
    let db = Firestore.firestore()
    
    var cellData : FeedData!{
    //监视器，判断是否发生变化
        didSet{
            labelT.text = cellData.title
            labelD.text = cellData.detail
            labelD.numberOfLines=0 // 行数设置为0

            // 换行的模式我们选择文本自适应
            labelD.lineBreakMode = NSLineBreakMode.byWordWrapping

            let imageId : String! = cellData!.image
            let cloudFileRef = storage.reference(withPath: "activity-images/"+imageId)
            print("activity-images/"+imageId)
            cloudFileRef.getData(maxSize: 1*1024*1024) { (data, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    self.feedImage.image = UIImage(data: data!)
                }
            }
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
