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
        
        //refresh reloader
        SFContentBlockerManager.reloadContentBlocker(withIdentifier: "com.Christian.DistractionFree-App.DistractionBlock", completionHandler: { error in
            print(error)
        })
        
        //directory for files
//        print(Bundle.main.bundleURL)
//        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
//        print(FileManager.default.temporaryDirectory)
        
        //user defaults example
//        UserDefaults.standard.set("Christian", forKey: "name")
//        print(UserDefaults.standard.string(forKey: "name"))

    

        
    }
    
    @IBAction func AddRule(_ sender: UISwitch) {
        guard let taskJSONURL = Bundle.main.url(forResource: "rules", withExtension: "json") else {
            return
        }
        let decoder = JSONDecoder()
        let encoder = JSONEncoder()

        do {
            let taskData = try Data(contentsOf: taskJSONURL)
    
            let task = try decoder.decode([Rule].self, from: taskData)
            
            let exportData = try encoder.encode(task)
            let groupUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.distract")
            print(groupUrl)
            let exportJsonURL = URL(fileURLWithPath: "export", relativeTo: groupUrl).appendingPathExtension("json")
            
            try exportData.write(to: exportJsonURL)
            
        } catch let error {
            print(error)
        }
        
        
        
        SFContentBlockerManager.reloadContentBlocker(withIdentifier: "com.Christian.DistractionFree-App.DistractionBlock", completionHandler: { error in
                    print(error)
        })
    }

    @IBAction func Toggle(_ sender: UISwitch) {
        
        //read json file in bundle
        guard let taskJSONURL = Bundle.main.url(forResource: "rules", withExtension: "json") else {
            return
        }
        
        //read json file stored in user directory
//        let taskJSONURL = URL(fileURLWithPath: "rules", relativeTo: getDocumentsDirectory()).appendingPathExtension("json")
        
//        let taskJSONURL = URL(fileURLWithPath: "rules", relativeTo: FileManager.default.temporaryDirectory).appendingPathExtension("json")
        
//        guard let JSONURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.distract") else {
//            print("not found file")
//            return
//        }
        
//        let taskJSONURL = URL(fileURLWithPath: "rules", relativeTo: JSONURL).appendingPathExtension("json")
        
//        print(taskJSONURL)
        
          
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .custom { keys in

            var lastComponent = keys.last!.stringValue
            if let i = lastComponent.firstIndex(of: "-") {
                lastComponent.remove(at: i)
            }
            return AnyKey(stringValue: String(lastComponent))!
        }

        do {
            let taskData = try Data(contentsOf: taskJSONURL)
    
            let task = try decoder.decode([Rule].self, from: taskData)
            for t in task {
                print("name")
                print(t.name)
                print ("action")
                print (t.action)
                print ("trigger")
                print (t.trigger)
            }
            
        } catch let error {
            print(error)
        }
        
    
        if (sender.isOn) {
            
        } else {
            
        }
    }
    
    
    
    
    
    
    //
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}

