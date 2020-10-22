//
//  FeedCell.swift
//  Messager
//
//  Created by zhangchongjing on 2020/10/9.
//

import UIKit
import Firebase
import DOFavoriteButtonNew

class FeedCell: UITableViewCell {
    @IBOutlet weak var profile5: UIImageView!
    @IBOutlet weak var profile4: UIImageView!
    @IBOutlet weak var profile3: UIImageView!
    @IBOutlet weak var profile2: UIImageView!
    @IBOutlet weak var profile1: UIImageView!
    @IBOutlet weak var labelD: UILabel!
    @IBOutlet weak var labelT: UILabel!
    @IBOutlet weak var feedImage: UIImageView!
    @IBOutlet weak var view: UIView!
    
    @IBOutlet weak var btn: UIButton!
    
    @IBOutlet weak var bbb: DOFavoriteButtonNew!
    
    let storage = Storage.storage()
    let db = Firestore.firestore()
    
    var cellData : FeedData!{
    //监视器，判断是否发生变化
        didSet{
            bbb.addTarget(self, action: #selector(self.tappedButton), for: .touchUpInside)
            labelT.text = cellData.title
            labelD.text = cellData.detail
            labelD.numberOfLines=0 // 行数设置为0
            // 换行的模式 文本自适应
            labelD.lineBreakMode = NSLineBreakMode.byWordWrapping
            //print("cellData.user1："+cellData.user1!)
            
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
            
            let p1 : String! = cellData!.user1
            let p2 : String! = cellData!.user2
            
            if(p1 != ""){
                let proRef = storage.reference(withPath: "user-photoes/"+p1)
                print("user-photoes/"+p1)
                proRef.getData(maxSize: 1*1024*1024) { (data, error) in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        self.profile1.image = UIImage(data: data!)
                    }
                }
            }
            if(p2 != ""){
                let proRef = storage.reference(withPath: "user-photoes/"+p2)
                print("user-photoes/"+p2)
                proRef.getData(maxSize: 1*1024*1024) { (data, error) in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        self.profile2.image = UIImage(data: data!)
                    }
                }
            }
        }
    }
    
    //点击触发
    @objc func tappedButton(sender: DOFavoriteButtonNew) {
        if sender.isSelected {
            sender.deselect()
        } else {
            sender.select()
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
