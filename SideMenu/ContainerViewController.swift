//
//  ContainerViewController.swift
//  BeUnique
//
//  Created by Anupriya on 08/01/19.
//  Copyright © 2019 com.smartitventures. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift
import NotificationCenter
class ContainerViewController: SlideMenuController {
    
    override func awakeFromNib() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notificationLang"), object: nil)
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController"){
            self.mainViewController = controller
        }
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "LeftMenuViewController")  {
            self.leftViewController = controller
        }
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "LeftMenuViewController")  {
            self.rightViewController = controller
        }
        //        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "NotificationViewController") {
        //        self.rightViewController = controller
        //        }
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       //  NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notificationLang"), object: nil)
     //   NotificationCenter.default.addObserver(self, selector: #selector(self.languageDidChange), name: NSNotification.Name(rawValue: "notificationLang"), object: nil)
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func languageDidChange(){
//        let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
//        appDelegate?.ChangeLayout()
    }
}

