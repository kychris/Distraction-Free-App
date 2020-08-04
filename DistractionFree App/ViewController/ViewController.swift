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
    let ruleNum: Int = 2

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        for i in 1...ruleNum {
            var tmpButton = self.view.viewWithTag(i) as? UISwitch
            var curRuleName = ruleNames[i-1]
            tmpButton?.isOn = UserDefaults.standard.bool(forKey: curRuleName)
        }
        
        resetCache()
        detectContentBlockerEnabling()
        
        //refresh reloader
        SFContentBlockerManager.reloadContentBlocker(withIdentifier: "com.Christian.DistractionFree-App.DistractionBlock", completionHandler: { error in
            print(error)
        })
    }
    
    @IBAction func AddRule(_ sender: UISwitch) {
        
        let toggleName: String = ruleNames[sender.tag-1]
        
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
    
    
    //reset save json file
    func resetCache() {
        //start coders
        let decoder = JSONDecoder()
        let encoder = JSONEncoder()
        do {
            var exportList: [Rule] = [] //final export
            //read rule list json
            guard let taskJSONURL = Bundle.main.url(forResource: "rules", withExtension: "json") else {
                return
            }
            let rules = try Data(contentsOf: taskJSONURL)
            let ruleList = try decoder.decode([Rule].self, from: rules)
            
            //append default and rules that are true
            exportList.append(ruleList[0])
            for rule in ruleList {
                if (UserDefaults.standard.bool(forKey: rule.name)) {
                    exportList.append(rule)
                }
            }
            
            //export new selected rules to group
            let groupUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.distract")
            let exportJsonURL = URL(fileURLWithPath: "export", relativeTo: groupUrl).appendingPathExtension("json")
            let exportData = try encoder.encode(exportList)
            try exportData.write(to: exportJsonURL)
            
            
            
            //refresh blocker
            SFContentBlockerManager.reloadContentBlocker(withIdentifier: "com.Christian.DistractionFree-App.DistractionBlock", completionHandler: { error in
                print(error)
            })
            
        } catch let error {
            print("Me created: Reset Cache ERROR")
            print(error)
        }
    }
    
    func detectContentBlockerEnabling() {
        SFContentBlockerManager.getStateOfContentBlocker(withIdentifier: "com.Christian.DistractionFree-App.DistractionBlock", completionHandler: { (state, error) in
            if let error = error {
                print(error)
            }
            if let state = state {
                let contentBlockerIsEnabled = state.isEnabled
                if(!contentBlockerIsEnabled) {
                    let alert = UIAlertController(title: "Please enable content blocker", message: "Go to settings->Safari->content blocker, then restart the app", preferredStyle: .alert)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        })
    }
    @IBAction func testButton(_ sender: UIButton) {
        resetCache()
    }
    
    //
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}

