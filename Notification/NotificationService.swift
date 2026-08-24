//
//  NotificationService.swift
//  notification
//
//  Created by Axeraan Technologies on 10/03/21.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {

            self.contentHandler = contentHandler
            bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

            if let bestAttemptContent = bestAttemptContent {
                if let urlString = bestAttemptContent.userInfo["media_attachment"] as? String,
                    let data = NSData(contentsOf: URL(string:urlString)!) as Data? {
                    let path = NSTemporaryDirectory() + "attachment"
                    _ = FileManager.default.createFile(atPath: path, contents: data, attributes: nil)

                    do {
                        let file = URL(fileURLWithPath: path)
                        let attachment = try UNNotificationAttachment(identifier: "attachment", url: file,options:[UNNotificationAttachmentOptionsTypeHintKey : "public.jpeg"])
                        bestAttemptContent.attachments = [attachment]

                    } catch {
                        print(error)

                    }
                }

                contentHandler(bestAttemptContent)
            }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
