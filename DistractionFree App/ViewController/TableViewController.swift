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


extension UIView {

    func subviewsRecursive() -> [UIView] {
        return subviews + subviews.flatMap { $0.subviewsRecursive() }
    }

}


class TableViewController: UITableViewController {
    
    let ruleNames: [String] = ["InsFeed","InsExplore","InsNotification","FbFeed","FbNotification","FbMessenger","YtFeed","YtRelated","YtComments"]
    let ruleMobile: [String:String] = ["GoogleBlock":"FacebookBlock"]
    let ruleNum: Int = 3
    
    @IBOutlet weak var InsFeed: UISwitch!
    @IBOutlet weak var InsExplore: UISwitch!
    @IBOutlet weak var InsNotification: UISwitch!
    
    @IBOutlet weak var FbFeed: UISwitch!
    @IBOutlet weak var FbNotification: UISwitch!
    @IBOutlet weak var FbMessenger: UISwitch!
    
    @IBOutlet weak var YtFeed: UISwitch!
    @IBOutlet weak var YtRelated: UISwitch!
    @IBOutlet weak var YtComments: UISwitch!
    
    var switches: [UISwitch] = []
    
    let vc = UIViewController()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        switches.append(contentsOf: [InsFeed,InsExplore,InsNotification,FbFeed,FbNotification,FbMessenger,YtFeed,YtRelated,YtComments])
        
        for i in 0..<ruleNames.count {
            switches[i].isOn = UserDefaults.standard.bool(forKey: ruleNames[i])
        }
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        appMovedToForeground()
        //reset system
        resetCache() //careful with buddy system
        refreshContentBlockerStatus()
        refreshBlocker()
        
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        refreshContentBlockerStatus()
//        if (!UserDefaults.standard.bool(forKey: "ContentBlockerStatus")) {
//            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//            let newViewController = storyBoard.instantiateViewController(withIdentifier: "test") as! InstructionViewController
////            let newViewController = UIViewController()
//            newViewController.modalPresentationStyle = .fullScreen
//            self.present(newViewController, animated: true, completion: nil)
//            print("sasdhasjdhajksdh")
//        }
//
//    }

    @objc func appMovedToForeground() {
        refreshContentBlockerStatus()
        print("called")
         if (!UserDefaults.standard.bool(forKey: "ContentBlockerStatus")) {
             let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
             let newViewController = storyBoard.instantiateViewController(withIdentifier: "test") as! InstructionViewController
    //            let newViewController = UIViewController()
             newViewController.modalPresentationStyle = .fullScreen
             self.present(newViewController, animated: true, completion: nil)
             
        }
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
    
    func refreshContentBlockerStatus(){
        SFContentBlockerManager.getStateOfContentBlocker(withIdentifier: "com.Christian.DistractionFree-App.DistractionBlock", completionHandler: { (state, error) in
            if let error = error {
                print(error)
            }
            if let state = state {
                let contentBlockerIsEnabled = state.isEnabled
                UserDefaults.standard.set(contentBlockerIsEnabled, forKey: "ContentBlockerStatus")
            }
        })
        
    }
    

    @IBAction func OpenFirstApp(_ sender: Any) {
        //open using built in browser
        if let url = URL(string: "http://www.instagram.com") {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true

            let vc = SFSafariViewController(url: url, configuration: config)
            present(vc, animated: true)
        }
        //open using safari browser
//        if let url = URL(string: "https://www.instagram.com") {
//            UIApplication.shared.open(url)
//        }
    }
    
    @IBAction func OpenSecondApp(_ sender: UIButton) {
        if let url = URL(string: "http://www.facebook.com") {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true

            let vc = SFSafariViewController(url: url, configuration: config)
            present(vc, animated: true)
        }
    }
    
    @IBAction func OpenThirdApp(_ sender: UIButton) {
        if let url = URL(string: "http://www.youtube.com") {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true

            let vc = SFSafariViewController(url: url, configuration: config)
            present(vc, animated: true)
        }
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

