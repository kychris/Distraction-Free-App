//
//  SecondInstructionViewController.swift
//  DistractionFree App
//
//  Created by Christian Yang on 8/27/20.
//  Copyright © 2020 Christian. All rights reserved.
//

import Foundation
import UIKit
import SafariServices



class SecondInstructionViewController: UIViewController {

    @IBAction func dismissInstruction(_ sender: UIButton) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "MainViewController") as! TableViewController
        newViewController.modalPresentationStyle = .fullScreen
        self.present(newViewController, animated: true, completion: nil)
    }
    
}
    
