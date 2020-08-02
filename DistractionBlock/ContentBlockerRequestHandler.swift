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
//        let attachment = NSItemProvider(contentsOf: Bundle.main.url(forResource: "rules", withExtension: "json"))!
        
//        let taskJSONURL = URL(fileURLWithPath: "rules", relativeTo: FileManager.default.temporaryDirectory).appendingPathExtension("json")
//
        
        let groupUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.distract")
        let taskJSONURL = URL(fileURLWithPath: "export", relativeTo: groupUrl).appendingPathExtension("json")
        
        
        
        let attachment = NSItemProvider(contentsOf: taskJSONURL)!
        let item = NSExtensionItem()
        item.attachments = [attachment]
        context.completeRequest(returningItems: [item], completionHandler: nil)
        
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        print(documentsDirectory)
        return documentsDirectory
    }
    
}
