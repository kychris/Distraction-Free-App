//
//  ViewController.swift
//  DistractionFree App
//
//  Created by Christian Yang on 7/26/20.
//  Copyright © 2020 Christian. All rights reserved.
//

import UIKit
import DistractionBlock
import SafariServices



class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        SFContentBlockerManager.reloadContentBlocker(withIdentifier: "com.Christian.DistractionFree-App.DistractionBlock", completionHandler: { error in
            print(error)
        })
    }

    @IBAction func Toggle(_ sender: UISwitch) {
        
//        guard let taskJSONURL = Bundle.main.url(forResource: "test", withExtension: "json") else {
//            return
//        }
//          
//        let decoder = JSONDecoder()
//        decoder.keyDecodingStrategy = .custom { keys in
//
//            var lastComponent = keys.last!.stringValue
//            if let i = lastComponent.firstIndex(of: "-") {
//                lastComponent.remove(at: i)
//            }
//            return AnyKey(stringValue: String(lastComponent))!
//        }
//
//        do {
//            let taskData = try Data(contentsOf: taskJSONURL)
//    
//            let task = try decoder.decode([Rule].self, from: taskData)
//            for t in task {
////                print ("action")
////                print (t.action)
////                print ("trigger")
////                print (t.trigger)
//            }
//            
//        } catch let error {
//            print("not find file")
//        }
//        
//    
//        if (sender.isOn) {
//            
//        } else {
//            
//        }
    }
    
}

