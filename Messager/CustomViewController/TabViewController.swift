//
//  TabViewController.swift
//  Messager
//
//  Created by Boyang Zhang on 12/10/20.
//

import UIKit



class TabViewController: UIViewController {
    
    
    
    
    //
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var tabBarView: UIView!
    
    //
    @IBOutlet weak var feedBttn: UIButton!
    @IBOutlet weak var chatBttn: UIButton!
    @IBOutlet weak var addBttn: UIButton!  // special Tab Button
    @IBOutlet weak var peopleBttn: UIButton!
    @IBOutlet weak var meBttn: UIButton!
    
    @IBOutlet weak var feedImage: UIImageView!
    @IBOutlet weak var chatImage: UIImageView!
    @IBOutlet weak var peopleImage: UIImageView!
    @IBOutlet weak var meImage: UIImageView!
    @IBOutlet weak var addBackgroundImage: UIImageView!
    
    private var buttons: [UIButton]!
    private var buttonImages: [UIImageView]!
        
    //Define variables to hold each ViewController associated with a tab.
    var feedViewController: UIViewController!
    var chatViewController: UIViewController!
    var addViewController: UIViewController! // special Tab VC
    var peopleViewController: UIViewController!
    var meViewController: UIViewController!
    var viewControllers: [UIViewController]!
    var meNavigationController: UIViewController!
    
    private var selectedIndex: Int = 0

   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        feedViewController = storyboard.instantiateViewController(withIdentifier: "feedVC")
        chatViewController = storyboard.instantiateViewController(withIdentifier: "chatNavVC")

        peopleViewController = storyboard.instantiateViewController(withIdentifier: "peopleNavVC")
        meViewController = storyboard.instantiateViewController(withIdentifier: "meVC")
        meNavigationController = storyboard.instantiateViewController(withIdentifier: "meNC")
        
        
        viewControllers = [feedViewController, chatViewController, peopleViewController, meNavigationController]
        
        buttons = [feedBttn, chatBttn, peopleBttn, meBttn]
        buttonImages = [feedImage, chatImage, peopleImage, meImage]
        
        
        // Init Setup
        tabBttnPressed(buttons[selectedIndex])
        
        // UI
        addBackgroundImage.layer.cornerRadius = 8
    }
    

    
    @IBAction func tabBttnPressed(_ sender: UIButton) {
        let previousIndex = selectedIndex
        selectedIndex = sender.tag
        
        // Step: Remove previous VC & Button
        for image in buttonImages {
            image.isHighlighted = false
        }
        let previousVC = viewControllers[previousIndex]
        
        previousVC.willMove(toParent: nil)
        previousVC.view.removeFromSuperview()
        previousVC.removeFromParent()
        
        // Step: Add New VC & Button
        buttonImages[selectedIndex].isHighlighted = true
        
        let vc = viewControllers[selectedIndex]
        addChild(vc)
        //Adjust the size of the ViewController view you are adding to match the contentView of your tabBarViewController and add it as a subView of the contentView.
        vc.view.frame = contentView.bounds
        contentView.addSubview(vc.view)
        
        // Call the viewDidAppear method of the ViewController you are adding using didMove(toParentViewController: self).
        vc.didMove(toParent: self)
        
        
        
    }
    
    @IBAction func addBttnPressed(_ sender: UIButton) {
        
    }
    @IBOutlet weak var tabHeightConstraint: NSLayoutConstraint!
    
    public func hideTabBar() {
        self.tabBarView.isHidden = true
        self.tabHeightConstraint.constant = 0
    }

    public func showTabBar() {
        self.tabBarView.isHidden = false
        self.tabHeightConstraint.constant = 80
    }
    
}
