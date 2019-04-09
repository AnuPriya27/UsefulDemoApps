//
//  SecondViewController.swift
//  CustomRefreshControl
//
//  Created by Anupriya on 09/04/19.
//  Copyright © 2019 SliCode. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
    @IBOutlet weak var tblNum : UITableView!
    var items = [1,2,3,4,5,6,7,8,9,10,11,12,13]
    //,11,12,13,14,1516,17,18,19,20,21,22,23,24,25
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
}

extension SecondViewController : UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NumberTableViewCell") as! NumberTableViewCell
        cell.lblNum.text = "This is item Num : \(self.items[indexPath.row])."
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let threshold   = 100.0 ;
        let contentOffset = scrollView.contentOffset.y;
        let contentHeight = scrollView.contentSize.height;
        let diffHeight = contentHeight - contentOffset;
        let frameHeight = scrollView.bounds.size.height;
        var triggerThreshold  = Float((diffHeight - frameHeight))/Float(threshold);
        triggerThreshold   =  min(triggerThreshold, 0.0)
        let pullRatio  = min(fabs(triggerThreshold),1.0);
        print("pullRation:\(pullRatio)")
    }
    
    
    //compute the offset and call the load method
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset.y;
        let contentHeight = scrollView.contentSize.height;
        let diffHeight = contentHeight - contentOffset;
        let frameHeight = scrollView.bounds.size.height;
        let pullHeight  = fabs(diffHeight - frameHeight);
        print("pullHeight:\(pullHeight)");
        if pullHeight == 0.0
        {
            DispatchQueue.global(qos: .userInteractive).async {
                for i:Int in (self.items.count + 1)...(self.items.count + 5) {
                    self.items.append(i)
                }
                DispatchQueue.main.async {
                    self.tblNum.reloadData()
                }
            }
        }
    }
}

extension SecondViewController : UITableViewDelegate {
    
    /*func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        if indexPath.section == lastSectionIndex && indexPath.row == lastRowIndex {
           
        }
    }*/
}

class NumberTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblNum : UILabel!
    
    
    
}

