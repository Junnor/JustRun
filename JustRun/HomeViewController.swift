//
//  HomeViewController.swift
//  JustRun
//
//  Created by Ju on 2017/4/9.
//  Copyright © 2017年 Ju. All rights reserved.
//

import UIKit
import CoreData

class HomeViewController: UIViewController {
    
    var managedObjectContext: NSManagedObjectContext?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier != nil {
            if let newRunVC = segue.destination.contents as? NewRunViewController {
                newRunVC.managedObjectContext = managedObjectContext
            }
        }
    }

}
