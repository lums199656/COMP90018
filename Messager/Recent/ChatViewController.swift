//
//  ChatViewController.swift
//  Messager
//
//  Created by 陆敏慎 on 12/10/20.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import Gallery
// 用来保存 message
import RealmSwift

class ChatViewController: MessagesViewController {
    
    
    //MARK: - Views
    let leftBarButtonView: UIView = {
        return UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
    }()
    
    let titleLabel: UILabel = {
       let title = UILabel(frame: CGRect(x: 60, y: 10, width: 180, height: 25))
        title.textAlignment = .center
        title.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        title.adjustsFontSizeToFitWidth = true
        return title
    }()
    
    let subTitleLabel: UILabel = {
       let subTitle = UILabel(frame: CGRect(x: 5, y: 22, width: 180, height: 20))
        subTitle.textAlignment = .left
        subTitle.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        subTitle.adjustsFontSizeToFitWidth = true
        return subTitle
    }()

    
    private var chatId = ""
    private var reipientId : [String] = []
    private var recipientName : [String] = []
    
    let currentUser = MKSender(senderId: User.currentId, displayName: User.currentUser!.username)
    
    // 组件
    let refreshController = UIRefreshControl()
    let micButton = InputBarButtonItem()
    
    //一个聊天框内的所有聊天内容
    var mkMessages: [MKMessage] = []
    var allLocalMessages: Results<LocalMessage>!
    
    let realm = try! Realm()
    
    var notificationToken: NotificationToken?
    
    var longPressGesture: UILongPressGestureRecognizer!
    
    
    init(chatId: String, recipientId: [String], recipientName: [String]) {

        
        super.init(nibName: nil, bundle: nil)
        
        self.chatId = chatId
        self.reipientId = recipientId
        self.recipientName = recipientName
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configueMessageCollectionView()
        configureMessageInputBar()
        loadChats()
        listenForNewChats()
        configureLeftBarButton()
        configureCustomTitle()


        // _. Setup Shake Gesture
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("Chat Will Appear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("Chat Did Apear")
    }
    
    // MARK:- Shake Gesture
    override func becomeFirstResponder() -> Bool {  // For Shake Gesture
        super.becomeFirstResponder()
        return false
    }
  
    private var isUserAtActivityLocation: Bool {
        get {
            return checkIfUserAtActivityLocation()
        }
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            
            if isUserAtActivityLocation {
                print("👻Shimmy Shaky")
                // TODO: Send_a_special_message_with_UI()
                // TODO:
            } else {
                print("👻Get to the Activity location")
            }
            
            
            
        }
    }
    
//    private func actionAttachMessage() {
//
//        messageInputBar.inputTextView.resignFirstResponder()
//
//        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//
//        let takePhotoOrVideo = UIAlertAction(title: "Camera", style: .default) { (alert) in
//
//            self.showImageGallery(camera: true)
//        }
//
//        let shareMedia = UIAlertAction(title: "Library", style: .default) { (alert) in
//
//            self.showImageGallery(camera: false)
//        }
//
//        let shareLocation = UIAlertAction(title: "Share Location", style: .default) { (alert) in
//
//            if let _ = LocationManager.shared.currentLocation {
//                self.messageSend(text: nil, photo: nil, video: nil, audio: nil, location: kLOCATION)
//            } else {
//                print("no access to location")
//            }
//        }
//    }


    
    func updateMicButtonStatus(show: Bool) {
        
        if show {
            messageInputBar.setStackViewItems([micButton], forStack: .right, animated: false)
            messageInputBar.setRightStackViewWidthConstant(to: 30, animated: false)
        } else {
            messageInputBar.setStackViewItems([messageInputBar.sendButton], forStack: .right, animated: false)
            messageInputBar.setRightStackViewWidthConstant(to: 55, animated: false)
        }
    }
    
    // 设定 title
    private func configureCustomTitle() {
        
        leftBarButtonView.addSubview(titleLabel)
        leftBarButtonView.addSubview(subTitleLabel)
        titleLabel.frame(forAlignmentRect: CGRect(x: leftBarButtonView.bounds.midX, y: leftBarButtonView.bounds.midY, width: 200, height: 50))
        let leftBarButtonItem = UIBarButtonItem(customView: leftBarButtonView)
        
        self.navigationItem.leftBarButtonItems?.append(leftBarButtonItem)
        
        var tmpText = ""
        for i in recipientName {
            tmpText += " | " + i.prefix(4)
        }
        tmpText += " | \(User.currentUser!.username.prefix(4)) | "
        
        titleLabel.text = tmpText
    }
    
    private func configureLeftBarButton() {
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(self.backButtonPressed))]
    }
    
    @objc func backButtonPressed() {
        FirebaseRecentListener.shared.resetRecentCounter(chatRoomId: chatId)
        removeListeners()
        self.navigationController?.popViewController(animated: true)
    }
    
    private func removeListeners() {
//        FirebaseTypingListener.shared.removeTypingListener()
        FirebaseMessageListener.shared.removeListeners()
    }
    
    
    private func configueMessageCollectionView() {
        // 部署 message 界面需要的组件
        // 得补充 ChatViewExtension
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        // 下拉刷新
        messagesCollectionView.refreshControl = refreshController

        
        // 加上滚动功能
        // 当点击键盘时，会将聊天框滚动到底部
        scrollsToBottomOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
    }
    
    // 设置输入框
    private func configureMessageInputBar() {
        // 检测 bar 是否被检测
        messageInputBar.delegate = self
        // 照片按钮
        let attachButton = InputBarButtonItem()
        attachButton.image = UIImage(systemName: "plus")
        attachButton.setSize(CGSize(width: 30, height: 30), animated: false)
        attachButton.onTouchUpInside { item in
            print("attach button pressed")
        }
        micButton.image = UIImage(systemName: "mic.fill")
        micButton.setSize(CGSize(width: 30, height: 30), animated: false)
        
        // 将两个 button 放入布局, MessageKit 可以查看布局
        // imageButton
        messageInputBar.setStackViewItems([attachButton], forStack: .left, animated: false)
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        
        // textField
        // 不让用户能够在此处黏贴 image
        messageInputBar.inputTextView.isImagePasteEnabled = false
        messageInputBar.backgroundView.backgroundColor = .systemBackground
        messageInputBar.inputTextView.backgroundColor = .systemBackground
        
        //
        
    }
    
    
    
    // Message 的发送
    func messageSend(text: String?, photo: UIImage?, video: String?, audio: String?, location: String?, audioDuration: Float = 0.0) {
        print("_x 发送信息")
        OutgoingMessage.send(chartId: chatId, text: text!, photo: photo, video: video, audio: audio, location: location, memberIds: [User.currentId] + reipientId)
    }
    
    private func insertMessage(_ localMessage: LocalMessage) {
        
        let incoming = IncomingMessage(_collectionView: self)
        self.mkMessages.append(incoming.createMessage(localMessage: localMessage)!)
//        displayingMessagesCount += 1
    }
    
    // 插入信息以待展示
    private func insertMessages() {
        for message in allLocalMessages {
            insertMessage(message)
        }
    }
    
    
    // 检测是否有新的信息
    private func listenForNewChats() {
        FirebaseMessageListener.shared.listenForNewChats(User.currentId, collectionId: chatId, lastMessageDate: lastMessageDate())
    }
    private func lastMessageDate() -> Date {
        let lastMessageDate = allLocalMessages.last?.date ?? Date()
        return Calendar.current.date(byAdding: .second, value: 1, to: lastMessageDate) ?? lastMessageDate
    }

    
    //MARK: - Load Chats
    private func loadChats() {
                
        let predicate = NSPredicate(format: "chatRoomId = %@", chatId)

        allLocalMessages = realm.objects(LocalMessage.self).filter(predicate).sorted(byKeyPath: kDATE, ascending: true)
        print("_x-10 这个聊天框: \(chatId) 我们有 \(allLocalMessages.count) messages")

        
        // 从 firebase 下载数据保存到 localdb
//        if allLocalMessages.isEmpty {
//            checkForOldChats()
//        }
//
        notificationToken = allLocalMessages.observe({ (changes: RealmCollectionChange) in

            //updated message
            switch changes {
            // 新增
            case .initial:
                self.insertMessages()
                self.messagesCollectionView.reloadData()
                // 始终显示最下面
                self.messagesCollectionView.scrollToBottom(animated: true)
            
            //更改
            case .update(_, _ , let insertions, _):

                for index in insertions {
                    // 将每个 message 渲染出来
                    self.insertMessage(self.allLocalMessages[index])
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToBottom(animated: false)
                }

            case .error(let error):
                print("Error on new insertion", error.localizedDescription)
            }
        })
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
