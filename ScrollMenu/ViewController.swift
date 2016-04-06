//
//  ViewController.swift
//  ScrollMenu
//
//  Created by dungvh on 4/6/16.
//  Copyright © 2016 dungvh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var scrollMenu: ScrollMenuView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        scrollMenu.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func tapByReload(sender: AnyObject) {
        scrollMenu.reloadData()
    }

    @IBAction func tapByDelete(sender: AnyObject) {
        scrollMenu.removeFromSuperview()
    }
}

extension ViewController:ScrollMenuDataSource{
    // Title
    func scrollMenuTitles() -> [String]
    {
        return ["gfdagfd","dadasd","ksdksjdjskajdk","hds","jdsjdjhsjdhjshdjshdjhsj"]
    }
    func scrollMenuFontTitle() -> UIFont
    {
        return UIFont.systemFontOfSize(40)
    }
    
    func scrollMenuColorTitle() -> UIColor{
        return UIColor.redColor()
    }
    
    func scrollMenuColorForSelectedItem() -> UIColor {
        return UIColor.blueColor()
    }
    
    // Setup Left, Spacing, Right
    func scrollMenuLeftInset() -> CGFloat
    {
        return 40
    }
    func scrollMenuSpacingForItem() -> CGFloat
    {
        return 20
    }
    func scrollMenuRightInset() -> CGFloat{
        return 40
    }
    
    // Indicator
    func scrollMenuHeightForIndicator() -> CGFloat{
        return 10
    }
    func scrollMenuColorForIndicator() -> UIColor{
        return UIColor.yellowColor()
    }
    
}

