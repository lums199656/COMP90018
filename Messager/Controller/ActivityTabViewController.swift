////
////  ActivityTabViewController.swift
////  Messager
////
////  Created by Boyang Zhang on 11/10/20.
////
//
//import UIKit
//import Tabman    // tab page view
//import Pageboy   // tab page view
//
//
//
//
//class ActivityTabViewController: TabmanViewController {
//    
//    enum Tab: String, CaseIterable {
//        case currentAct
//        case pastAct
//    }
//
//    private let tabItems = Tab.allCases.map({ BarItem(for: $0) })
//    private lazy var viewControllers = tabItems.compactMap({ $0.makeViewController() })
//
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        self.dataSource = self
//
//        // Create bar
//        let bar = TMBar.TabBar()
//        bar.layout.transitionStyle = .snap // Customize
//        
//
//        // Add to view
//        addBar(bar, dataSource: self, at: .top)
//        
//    }
//    
//    
//}
//
//
//
//// MARK:-
//extension ActivityTabViewController: PageboyViewControllerDataSource {
//
//    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
//        return viewControllers.count
//    }
//
//    func viewController(for pageboyViewController: PageboyViewController,
//                        at index: PageboyViewController.PageIndex) -> UIViewController? {
//        return viewControllers[index]
//    }
//
//    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
//        return nil
//    }
//}
//
//
//// MARK:- TMBarDataSource
//extension ActivityTabViewController:  TMBarDataSource {
//    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
//        return tabItems[index]
//    }
//}
//
//
//// MARK:-
//
//
//
//private class BarItem: TMBarItemable {
//    
//    let tab: ActivityTabViewController.Tab
//    
//    init(for tab: ActivityTabViewController.Tab) {
//        self.tab = tab
//    }
//    
//    private var _title: String? {
//        return tab.rawValue.capitalized
//    }
//    var title: String? {
//        get {
//            return _title
//        } set {}
//    }
//    
//    private var _image: UIImage? {
//        return UIImage(named: "ic_\(tab.rawValue)")
//    }
//    var image: UIImage? {
//        get {
//            return _image
//        } set {}
//    }
//    
//    var badgeValue: String?
//    
//    func makeViewController() -> UIViewController? {
//        let storyboardName: String
//        switch tab {
//        case .currentAct:
//            return ActivityTableViewController()
//        case .pastAct:
//            return PastActivityViewController()
//        }
//        
////        return UIStoryboard(name: storyboardName, bundle: nil).instantiateInitialViewController()
//        return UIViewController()
//    }
//}
//
//
