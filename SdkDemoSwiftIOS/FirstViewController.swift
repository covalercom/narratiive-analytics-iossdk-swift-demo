//
//  FirstViewController.swift
//  SdkDemoSwiftIOS
//
//  Created by David Lin on 21/6/20.
//  Copyright © 2020 Narratiive Audience Measurement. All rights reserved.
//

import UIKit
import NarratiiveSDK

class FirstViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let inst = NarratiiveSDK.sharedInstance() {
            inst.send(screenName: "/first-page")
        }
    }

}

