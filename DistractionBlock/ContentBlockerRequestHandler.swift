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
        let attachment = NSItemProvider(contentsOf: Bundle.main.url(forResource: "rules", withExtension: "json"))!
        print("hello")
//        let taskJSONURL = URL(fileURLWithPath: "rules", relativeTo: getDocumentsDirectory()).appendingPathExtension("json")
        
//        let attachment = NSItemProvider(contentsOf: taskJSONURL)!
        
        print(attachment)
        let item = NSExtensionItem()
        item.attachments = [attachment]
        context.completeRequest(returningItems: [item], completionHandler: nil)

        
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
}
