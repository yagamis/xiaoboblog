//
//  ViewController.swift
//  Blog
//
//  Created by yons on 16/8/7.
//  Copyright © 2016年 xiaobo. All rights reserved.
//

import UIKit
import SafariServices

class ViewController: UIViewController,SFSafariViewControllerDelegate {
    
    var link = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let url = URL(string: link)!
        
        let sf = SFSafariViewController(url: url)
        sf.delegate = self
        
        
        
        
        
    }
    


  

}

