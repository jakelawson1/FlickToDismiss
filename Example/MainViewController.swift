//
//  ViewController.swift
//  Example
//
//  Created by Jake Lawson on 04/06/2016.
//  Copyright © 2016 Jake Lawson. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Status bar
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

}
