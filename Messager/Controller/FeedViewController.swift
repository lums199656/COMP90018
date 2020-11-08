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
import CoreLocation
import NVActivityIndicatorView
import MapKit
import FirebaseFirestore

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let cur_id : String = Auth.auth().currentUser!.uid
    var lists : [FeedData] = []
    var cur_count = 0 //current row
    var max = 1 //max num
    var changeUID: String = "" //document id
    var pre_count = 0
    let locationManager = CLLocationManager()
    var lat: Double = 0.0
    var lont: Double = 0.0
    let db = Firestore.firestore()
     
    @IBOutlet weak var loadingView: NVActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!

    //显示cell个数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists.count
    }
    
    //每行显示什么
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! FeedCell
        print("current row=\(cur_count)")
//        cell.cellData = lists[indexPath.row]
//        let docRef = db.collection(K.FStore.act).document(cell.cellData.uid!)
//        docRef.getDocument { (document, error) in
//            if let document = document, document.exists {
//                let data = document.data()
//                cell.cellData.join = data!["join"] as! [String]
//            }
//        }
        
        
        let docRef = db.collection(K.FStore.act).document(lists[indexPath.row].uid!)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                self.lists[indexPath.row].category = data![K.Activity.category] as! String
                self.lists[indexPath.row].join = data![K.Activity.join] as! [String]
                self.lists[indexPath.row].title = data![K.Activity.title] as? String
                cell.cellData = self.lists[indexPath.row]
            }
        }
        
        changeUID = lists[indexPath.row].uid! //get current row uid
        //print("tableview changUID is: \(changeUID)")
        //如果row是0，先set read
        if cur_count == 0{
            setRead()
        }
        
//        cell.seeMoreBtn.tag = indexPath.row
//        cell.seeMoreBtn.addTarget(self, action: #selector(goDetail), for: .touchUpInside)
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none //none selection response of tableView
        return cell
    }
    
    //control cell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.size.height - 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ActivityDetail") as ActivityDetailController
        vc.activityID = lists[cur_count].uid!
        self.present(vc, animated: true, completion: nil)
    }
    
//    @objc func goDetail(sender : UIButton){
//        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ActivityDetail") as ActivityDetailController
//        vc.activityID = lists[cur_count].uid!
//        self.present(vc, animated: true, completion: nil)
//        //print("button changUID is: \(lists[cur_count].uid!)")
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //make page stable when reload
        tableView.estimatedRowHeight = 0
        print("🔥FeedView Did Load")
        
        // Setup Location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // add animation
        loadingView.startAnimating()
        getData(flag: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // toggle tabbar
        tableView?.scrollsToTop = false;
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
    
  
    //get data, if true find distance < 1000, else whatever
    func getData(flag: Bool){
        //.whereField().limit(to: num) .whereField("read", isEqualTo: 0)
        //whereField(_:notIn:) finds documents where a specified field’s value is not in a specified array.
        db.collection(K.FStore.act).getDocuments{ [self] (querySnapshot, error) in
            if let e = error{
                print("error happens in getDocuments\(e)" )
            }
            else{
                let page_limit = 10
                var page_load = 0
                var flag_load_page = 0
                if let snapShotDocuments = querySnapshot?.documents{
                    for doc in snapShotDocuments{
                        if(page_load >= page_limit){
                            page_load = 0
                            break
                        }
                        let data = doc.data()
                        //Assign data to create a structure and add it to the lists
                        if let detail = data[K.Activity.detail] as? String, let title = data[K.Activity.title] as? String, let uid = doc.documentID as? String, let image = data[K.Activity.image] as? String, let t = data[K.Activity.read_dict] as? [String : Int], let user = data[K.Activity.user] as? String, let size = data[K.Activity.groupSize] as? Int, let status = data[K.Activity.status] as? Int, let category = data[K.Activity.category] as? String, let ls = data[K.Activity.locationString] as? String{
                            //Must be forced to convert, otherwise it will become optional type data, can not get the value
                            let read = data["read_dic"] as! [String : Int] //unwrap
                            let join = data[K.Activity.join] as! [String]
                            let cur_size = join.count
                            //Initiate timestamp
                            let dateLong = data["startDate"] as! Timestamp
                            let date = dateLong.dateValue() as! Date
                            let df = DateFormatter()
                            df.dateFormat = "yyyy-MM-dd HH:mm:ss"
                            let endDate = df.string(from: date)
                            //get geopoint
                            let points = data[K.Activity.location] as? GeoPoint //latitude = points.latitude, longtitude = points.longtitude
                            var dis:CLLocationDistance = 1001
                            if points != nil{
                                let currentLocation = CLLocation(latitude: self.lat, longitude: self.lont) //get personal location
                                let targetLocation = CLLocation(latitude: points!.latitude, longitude: points!.longitude)
                                dis = currentLocation.distance(from: targetLocation)
                            }
                            let distance = Int(dis/1000)
                            //two point distance
                            // print("两点间距离是：\(distance)Km")
                            //print("user id: \(Auth.auth().currentUser!.uid)")

                            if flag{
                                if(read[self.cur_id] != 1 && status==0 && cur_size<size && distance<1000){//not in read_dic, status is awaiting, not reach size, distance<1000
                                    //print("进来了")
                                    page_load+=1
                                    flag_load_page+=1
                                    let feedData = FeedData(detail: detail, title: title, uid: uid, user: user, image: image, join: join, category: category, locationString: ls, distance: distance, groupSize: size, endDate: endDate)
                                    //print(feedData)
                                    self.lists.append(feedData)
                                    self.loadingView.stopAnimating()
                                    self.tableView.reloadData()
                                }
                            }
                            else{
                                if(read[self.cur_id] != 1 && status==0 && cur_size<size){//not in read_dic, status is awaiting, not reach size
                                    page_load+=1
                                    let feedData = FeedData(detail: detail, title: title, uid: uid, user: user, image: image, join: join,  category: category, locationString: ls, distance: distance, groupSize: size, endDate: endDate)
                                    //print(feedData)
                                    self.lists.append(feedData)
                                    self.loadingView.stopAnimating()
                                    self.tableView.reloadData()
                                }
                            }
                        }
                    }
                    // print("flag page:\(flag_load_page)")
                    if (flag_load_page == 0 || flag_load_page == 1) && flag{
                        self.getData(flag: false)
                    }
                    if self.lists.count==pre_count && !flag {
                        self.getData(flag: true)
                    }
                    else{
                        pre_count = self.lists.count
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
        if tableView.indexPathsForVisibleRows!.last?.row != nil{
            cur_count = tableView.indexPathsForVisibleRows!.last!.row
        }
        //downside
        if self.lastContentOffset < scrollView.contentOffset.y {
            if self.cur_count >= self.max {
                print("read")
                self.max += 1
                setRead()
            }
            if(self.cur_count >= self.lists.count - 1){
                getData(flag: true)
                print("getAgain")
                self.tableView.reloadData()
            }
        }
        //upside
        else if self.lastContentOffset > scrollView.contentOffset.y {
            print("upside")
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

extension FeedViewController: CLLocationManagerDelegate {
    
    // 2. Method when location is updated
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation: CLLocation = locations[0]
        
        lat = userLocation.coordinate.latitude
        lont = userLocation.coordinate.longitude
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clErr = error as? CLError {
            switch clErr {
            case CLError.locationUnknown:
                print("location unknown")
            case CLError.denied:
                print("denied")
            default:
                print("other Core Location error")
            }
        } else {
            print("other error:", error.localizedDescription)
        }
    }
    
//    func removeReadDict() {
//        db.collection("cities").document("LA").setData(["":nil])
//    }
    
}

