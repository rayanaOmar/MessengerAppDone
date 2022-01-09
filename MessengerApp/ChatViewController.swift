//
//  ViewController.swift
//  MessengerApp
//
//  Created by administrator on 07/01/2022.
//

import UIKit
import MessageKit

// message model
struct Message: MessageType {
    
    public var sender: SenderType // sender for each message
    public var messageId: String // id to de duplicate
    public var sentDate: Date // date time
    public var kind: MessageKind // text, photo, video, location, emoji
}

// sender model
struct Sender: SenderType {
    public var photoURL: String // extend with photo URL
    public var senderId: String
    public var displayName: String
}

class ChatViewController: MessagesViewController {
    private var messages = [Message]()
    private var seldSender = Sender(photoURL: "", senderId: "1", displayName: "rayana")

    override func viewDidLoad() {
        super.viewDidLoad()
        messages.append(Message(sender: seldSender, messageId: "1",sentDate: Date(),kind: .text("Hello World Mesaage")))
        messages.append(Message(sender: seldSender, messageId: "1",sentDate: Date(),kind: .text("Hello World Mesaage, Hello World Mesaage")))
        view.backgroundColor = .white

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self

        // Do any additional setup after loading the view.
    }
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        return seldSender
    }
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count

    }
}
