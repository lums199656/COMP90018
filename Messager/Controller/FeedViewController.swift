//
//  FeedViewController.swift
//  Messager
//
//  Created by Chongjing Zhang on 7/10/20.
//

import UIKit
import Firebase
import Lottie
import DOFavoriteButtonNew

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let cur_id : String = Auth.auth().currentUser!.uid
    var lists : [FeedData] = []
    var cur_count = 0 //current row
    var max = 1 //max num
    var changeUID: String = "" //document id
     
    @IBOutlet weak var tableView: UITableView!

    //显示cell个数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("list count")
        print(lists.count)
        return lists.count
    }
    
    //每行显示什么
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! FeedCell
        print("indexPath.row=\(indexPath.row)")
        cur_count = indexPath.row //define cur_count
        cell.cellData = lists[indexPath.row]
        changeUID = lists[indexPath.row].uid! //get current row uid
        //如果row是0，先set read
        if cur_count == 0{
            setRead()
        }
        cell.selectionStyle = UITableViewCell.SelectionStyle.none //none selection response of tableView
        return cell
    }
    
   
    let db = Firestore.firestore()
    let dbSeed = DBSeeding(false)
    
    //control cell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.size.height - 80
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //make page stable when reload
        tableView.estimatedRowHeight = 0
        print("🔥FeedView Did Load")
        getData()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // toggle tabbar
        print("😡")
        if let vcp = self.parent as? TabViewController {
            print("😃")
            vcp.showTabBar()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("🔥FeedView Did Disappear")
    }
    
  
    //get data
    func getData(){
        //.whereField().limit(to: num) .whereField("read", isEqualTo: 0)
        //whereField(_:notIn:) finds documents where a specified field’s value is not in a specified array.
        db.collection(K.FStore.act).getDocuments{ (querySnapshot, error) in
            if let e = error{
                print("error happens in getDocuments\(e)" )
            }
            else{
                let page_limit = 10
                var page_load = 0
                if let snapShotDocuments = querySnapshot?.documents{
                    for doc in snapShotDocuments{
                        if(page_load >= page_limit){
                            page_load = 0
                            break
                        }
                        let data = doc.data()
                        //Assign data to create a structure and add it to the lists
                        if let detail = data[K.Activity.detail] as? String, let title = data[K.Activity.title] as? String, let uid = doc.documentID as? String, let image = data[K.Activity.image] as? String, let t = data[K.Activity.read_dict] as? [String : Int], let user = data[K.Activity.user] as? String, let size = data[K.Activity.groupSize] as? Int, let status = data[K.Activity.status] as? Int{
                            //Must be forced to convert, otherwise it will become optional type data, can not get the value
                            let read = data["read_dic"] as! [String : Int] //unwrap
                            let join = data[K.Activity.join] as! [String]
                            let cur_size = join.count
                            
                            if(read[Auth.auth().currentUser!.uid] != 1 && status==0 && cur_size<size){//not in read_dic, status is awaiting, not reach size
                                print("coming")
                                page_load+=1
                                let feedData = FeedData(detail: detail, title: title, uid: uid, user: user, image: image, join: join)
                                //print(feedData)
                                self.lists.append(feedData)
                                self.tableView.reloadData()
                            }
                            print("abaaba")
                        }
                    }
                }
            }
        }
            
    }

    var lastContentOffset: CGFloat = 0
    var screenSize = UIScreen.main.bounds.size.height - 80

    // record offset
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.lastContentOffset = scrollView.contentOffset.y
    }

    //The method that will trigger the event when the sliding drag ends
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //downside
        if self.lastContentOffset < scrollView.contentOffset.y {
            if self.cur_count >= self.max {
                print("read")
                self.max += 1
                setRead()
            }
            if(self.cur_count >= self.lists.count - 1){
                getData()
                print("getAgain")
                self.tableView.reloadData()
            }
        }
        //upside
        else if self.lastContentOffset > scrollView.contentOffset.y {
              print("func2")
//            print(self.cur_count)
        }
    }
//    // during process
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//
//    }
    
    //remove duplication
    func setRead(){
        //self.db.collection(K.FStore.act).document(changeUID).updateData(["read_dict": FieldValue.arrayUnion([self.cur_id])]) array method
        let temp: String = "read_dic."+Auth.auth().currentUser!.uid
        self.db.collection(K.FStore.act).document(changeUID).updateData([temp:1])
    }
}


