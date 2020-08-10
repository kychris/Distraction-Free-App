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
    
    let ruleNames: [String] = ["GoogleBlock","InsButtons"]
    let ruleMobile: [String:String] = ["GoogleBlock":"FacebookBlock"]
    let ruleNum: Int = 2

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        for i in 1...ruleNum {
            var tmpButton = self.view.viewWithTag(i) as? UISwitch
            var curRuleName = ruleNames[i-1]
            tmpButton?.isOn = UserDefaults.standard.bool(forKey: curRuleName)
        }
        
        //reset system
//        resetCache() //careful with buddy system
        detectContentBlockerEnabling()
        refreshBlocker()
        
    }
    
    @IBAction func AddRule(_ sender: UISwitch) {
        let toggleName: String = ruleNames[sender.tag-1]
        let haveBuddy: Bool = haveMobileBuddy(cur: toggleName)
        
        if(sender.isOn) { //if toggle is enabled
            
            UserDefaults.standard.set(true, forKey: toggleName) //save setting to permanent storage
            
            //read, add rule, then export
            var exportList = readCurrentExport()
            let ruleList = getRules()
            exportList.append(findRule(ruleList: ruleList, toggleName: toggleName))
            
            //check mobile version, insert if exist
            if (haveBuddy) {
                let buddyName = ruleMobile[toggleName]!
                exportList.append(findRule(ruleList: ruleList, toggleName: buddyName))
            }
            
            writeToOutput(exportList: exportList)
            print(exportList)
            
            
            
        } else { //if sender is disabled
            
            UserDefaults.standard.set(false, forKey: toggleName) //save setting to permanent storage
            
            var exportList = readCurrentExport()
            
            for i in 0..<exportList.count { //remove current rule from output
                if exportList[i].name == toggleName {
                    if(exportList.count > 1) { //if export not empty, remove item
                        exportList.remove(at: i)
                        break
                    } else { //if export is empty, append placeholder
                        let ruleList = getRules()
                        exportList.append(ruleList[0])
                        exportList.remove(at: 0)
                    }
                }
            }
            
            if ( haveBuddy ) { //remove buddy if there is one
                let buddyName = ruleMobile[toggleName]!
                for i in 0..<exportList.count {
                    if exportList[i].name == buddyName {
                        if(exportList.count > 1) { //if export not empty, remove item
                            exportList.remove(at: i)
                            break
                        } else { //if export is empty, append placeholder
                            let ruleList = getRules()
                            exportList.append(ruleList[0])
                            exportList.remove(at: 0)
                        }
                    }
                }
            }
            
            writeToOutput(exportList: exportList)
            print(exportList)
        }
        
        refreshBlocker() //refreshed safari content blocker
    }
    
    func resetCache() {
        var exportList: [Rule] = []
        let ruleList = getRules()
        exportList.append(ruleList[0])
        for rule in ruleList {
            if (UserDefaults.standard.bool(forKey: rule.name)) {
                exportList.append(rule)
                
                if (haveMobileBuddy(cur: rule.name)) { //if rule have buddy
                    exportList.append(findRule(ruleList: ruleList, toggleName: ruleMobile[rule.name]!))
                }
            }
        }
        writeToOutput(exportList: exportList)
        refreshBlocker()
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
    
    
    //
    //helper functions
    //
    func readCurrentExport() -> [Rule] {
        let decoder = JSONDecoder()
        do {
            let groupUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.distract")
            let exportJsonURL = URL(fileURLWithPath: "export", relativeTo: groupUrl).appendingPathExtension("json")
            let exports = try Data(contentsOf: exportJsonURL)
            let exportList = try decoder.decode([Rule].self, from: exports)
            
            return exportList
        } catch let error {
            print(error)
            return []
        }
    }
    
    func writeToOutput(exportList: [Rule]) {
        let encoder = JSONEncoder()
        do {
            let groupUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.distract")
            let exportJsonURL = URL(fileURLWithPath: "export", relativeTo: groupUrl).appendingPathExtension("json")
            let exportData = try encoder.encode(exportList)
            try exportData.write(to: exportJsonURL)
        } catch let error {
            print(error)
        }
        refreshBlocker()
    }
    
    func refreshBlocker() {
        SFContentBlockerManager.reloadContentBlocker(withIdentifier: "com.Christian.DistractionFree-App.DistractionBlock", completionHandler: { error in
            print(error ?? "")
        })
    }
    
    func getRules() -> [Rule] {
        let decoder = JSONDecoder()
        do {
            guard let taskJSONURL = Bundle.main.url(forResource: "rules", withExtension: "json") else { return [] }
            let rules = try Data(contentsOf: taskJSONURL)
            let ruleList = try decoder.decode([Rule].self, from: rules)
            return ruleList
        } catch let error {
            print(error)
            return []
        }
    }
    
    func findRule(ruleList: [Rule], toggleName: String) -> Rule {
        for r in ruleList {
            if r.name == toggleName {
                return r
            }
        }
        return ruleList[0]
    }
    
    func haveMobileBuddy(cur: String) -> Bool {
        if let val = ruleMobile[cur] {
            return true
        } else {
            return false
        }
    }
 
}

