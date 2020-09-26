//
//  BrowserViewController.swift
//  DistractionFree App
//
//  Created by Christian Yang on 9/26/20.
//  Copyright © 2020 Christian. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import SafariServices


class BrowserViewController: UIViewController {
    
    
    @IBAction func clicked(_ sender: Any) {
        if let url = URL(string: "https://www.google.com") {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true

            let vc = SFSafariViewController(url: url, configuration: config)
            present(vc, animated: true)
        }
    }
    
    
    override func viewDidLoad() {
       
    }
    
}

