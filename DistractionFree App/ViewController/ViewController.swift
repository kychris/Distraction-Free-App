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
    
    let ruleNames: [String] = ["GoogleBlock","InstagramBlock"]
    

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
        UserDefaults.standard.set("Christian", forKey: "name")
//        print(UserDefaults.standard.dictionaryRepresentation())
        
        
        
    }
    
    @IBAction func AddRule(_ sender: UISwitch) {
        
        let toggleName: String = ruleNames[sender.tag]
        
        let decoder = JSONDecoder()
        let encoder = JSONEncoder()
        
        
        var ret: [Rule] = []
        
        guard let taskJSONURL = Bundle.main.url(forResource: "rules", withExtension: "json") else {
            return
        }
        
        var taskData: Data = Data()
        do {
            taskData = try Data(contentsOf: taskJSONURL)
        } catch let error {
            print(error)
            return
        }
        
        if(sender.isOn) { //if toggle is enabled
            UserDefaults.standard.set(true, forKey: toggleName)
            do {
                let groupUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.distract")
//                print(groupUrl)
                let exportJsonURL = URL(fileURLWithPath: "export", relativeTo: groupUrl).appendingPathExtension("json")
                var exports = try Data(contentsOf: exportJsonURL)
                var exportList = try decoder.decode([Rule].self, from: exports)
                
                let rules = try Data(contentsOf: taskJSONURL)
                let ruleList = try decoder.decode([Rule].self, from: rules)
                for r in ruleList {
                    if r.name == toggleName {
                        exportList.append(r)
                    }
                }
                
                print(exportList)
                
                let exportData = try encoder.encode(exportList)
                try exportData.write(to: exportJsonURL)
                
            } catch let error {
                print(error)
            }
            
        } else { //if sender is disabled
            UserDefaults.standard.set(false, forKey: toggleName)
            do {

                let groupUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.distract")
                let exportJsonURL = URL(fileURLWithPath: "export", relativeTo: groupUrl).appendingPathExtension("json")
                var exports = try Data(contentsOf: exportJsonURL)
                var exportList = try decoder.decode([Rule].self, from: exports)

                for i in 0..<exportList.count {
                    if exportList[i].name == toggleName {
                        if(exportList.count > 1) {
                            exportList.remove(at: i)
                            break
                        } else {
                            let rules = try Data(contentsOf: taskJSONURL)
                            let ruleList = try decoder.decode([Rule].self, from: rules)
                            exportList.append(ruleList[0])
                            exportList.remove(at: 0)
                        }
                    }
                }
   
                print(exportList)
                
                let exportData = try encoder.encode(exportList)
                try exportData.write(to: exportJsonURL)
            } catch let error {
                print(error)
            }
        }
        
        //refreshed safari content blocker
        SFContentBlockerManager.reloadContentBlocker(withIdentifier: "com.Christian.DistractionFree-App.DistractionBlock", completionHandler: { error in
                    print(error)
        })
    }

    @IBAction func Toggle(_ sender: UISwitch) {
        
        //read json file in bundle
        guard let taskJSONURL = Bundle.main.url(forResource: "rules", withExtension: "json") else {
            return
        }
          
        let decoder = JSONDecoder()

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
                print ("================")
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

