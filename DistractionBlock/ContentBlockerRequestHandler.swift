//
//  ContentBlockerRequestHandler.swift
//  DistractionBlock
//
//  Created by Christian Yang on 7/26/20.
//  Copyright © 2020 Christian. All rights reserved.
//

import UIKit
import MobileCoreServices

class ContentBlockerRequestHandler: NSObject, NSExtensionRequestHandling {

    func beginRequest(with context: NSExtensionContext) {
//        let attachment = NSItemProvider(contentsOf: Bundle.main.url(forResource: "blockerList", withExtension: "json"))!
//        print(attachment)
//        let item = NSExtensionItem()
//        item.attachments = [attachment]
//        context.completeRequest(returningItems: [item], completionHandler: nil)
//
        let documentFolder = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.distractionfree")

        guard let jsonURL = documentFolder?.appendingPathComponent("test.json") else {
            return
        }

        let attachment = NSItemProvider(contentsOf: jsonURL)!

        let item = NSExtensionItem()
        item.attachments = [attachment]
        
        context.completeRequest(returningItems: [item], completionHandler: nil)
    }
    
}
