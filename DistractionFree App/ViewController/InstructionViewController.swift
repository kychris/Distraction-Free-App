//
//  InstructionViewController.swift
//  DistractionFree App
//
//  Created by Christian Yang on 8/13/20.
//  Copyright © 2020 Christian. All rights reserved.
//

import Foundation
import UIKit
import SafariServices



class InstructionViewController: UIViewController {
    
    @IBAction func next(_ sender: Any) {
        refreshContentBlockerStatus()
        if (!UserDefaults.standard.bool(forKey: "ContentBlockerStatus")) {
            let alertController = UIAlertController(title: "Not enabled", message:
                   "Please enable content blocker settings before proceed", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))

            self.present(alertController, animated: true, completion: nil)
        } else {
//            self.dismiss(animated: true, completion: nil)
            
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "SecondInstruction") as! SecondInstructionViewController
            newViewController.modalPresentationStyle = .fullScreen
            self.present(newViewController, animated: true, completion: nil)
//            self.dismiss(animated: true, completion: nil)
        }
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
}
