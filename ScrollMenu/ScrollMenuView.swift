//
//  ScrollMenuView.swift
//  ScrollMenu
//
//  Created by dungvh on 4/6/16.
//  Copyright © 2016 dungvh. All rights reserved.
//

import Foundation
import UIKit

protocol ScrollMenuDataSource:class {
    // Title
    func scrollMenuTitles() -> [String]
    func scrollMenuFontTitle() -> UIFont
    func scrollMenuColorTitle() -> UIColor
    func scrollMenuColorForSelectedItem() -> UIColor
    
    // Setup Left, Spacing, Right
    func scrollMenuLeftInset() -> CGFloat
    func scrollMenuSpacingForItem() -> CGFloat
    func scrollMenuRightInset() -> CGFloat
    
    // Indicator
    func scrollMenuHeightForIndicator() -> CGFloat
    func scrollMenuColorForIndicator() -> UIColor
}

@objc protocol ScrollMenuDelegate:class {
    optional func scrollMenuDidSelectAtIndex(menuView:ScrollMenuView,index:Int)
}

let kTagLabel = 200
class ScrollMenuLabel: UILabel {
    private var gesture:UITapGestureRecognizer?
    init(frame:CGRect,gesture:UITapGestureRecognizer?){
        super.init(frame: frame)
        self.gesture = gesture
        
        if let tap = self.gesture {
            self.userInteractionEnabled = true
            self.addGestureRecognizer(tap)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func removeFromSuperview() {
        
        if let tap = self.gesture {
            self.removeGestureRecognizer(tap)
        }
        super.removeFromSuperview()
    }
    
    deinit{
        print("\(#function) class:\(self.dynamicType)")
    }
    
    
}

class ScrollMenuView: UIView {
    
    weak var delegate:ScrollMenuDelegate?
    weak var dataSource:ScrollMenuDataSource!{
        didSet{
            reloadData()
        }
    }
    
    lazy var scrollView:UIScrollView = {
       return self.setupScrollView()
    }()
    
    private var indicator:UIView!
    private var currentIndex:Int = 0
    // Setup Scroll View
    private func setupScrollView() -> UIScrollView{
        let scrollView = UIScrollView(frame: CGRectZero)
        scrollView.backgroundColor = UIColor.greenColor()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(scrollView)
        if #available(iOS 9.0, *) {
            scrollView.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true
            scrollView.leftAnchor.constraintEqualToAnchor(self.leftAnchor).active = true
            scrollView.rightAnchor.constraintEqualToAnchor(self.rightAnchor).active = true
            scrollView.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor).active = true
        } else {
            // Fallback on earlier versions
            let top = NSLayoutConstraint(item: scrollView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0)
            let left = NSLayoutConstraint(item: scrollView, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 0)
            let right = NSLayoutConstraint(item: scrollView, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: 0)
            let bottom = NSLayoutConstraint(item: scrollView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0)
            
            NSLayoutConstraint.activateConstraints([top,left,right,bottom])
        }
        
        return scrollView
    }
    
    func reloadData(){
        let leftInset = self.dataSource.scrollMenuLeftInset()
        let spacingItem = self.dataSource.scrollMenuSpacingForItem()
        let rightInset = self.dataSource.scrollMenuRightInset()
        
        let font = self.dataSource.scrollMenuFontTitle()
        let color = self.dataSource.scrollMenuColorTitle()
        let selectedColor = self.dataSource.scrollMenuColorForSelectedItem()
        
        currentIndex = 0
        
        // Setup Scroll View
        let heightIndicator = self.dataSource.scrollMenuHeightForIndicator()
        let newFrameIndicator = CGRectMake(leftInset, CGRectGetHeight(self.bounds) - heightIndicator , 0, heightIndicator)
        
        if indicator == nil {
            indicator = UIView(frame: CGRectZero)
            indicator.backgroundColor = self.dataSource.scrollMenuColorForIndicator()
            self.scrollView.addSubview(indicator)
        }
        
        indicator.frame = newFrameIndicator
        scrollView.contentOffset = CGPointZero
        
        // Remove All Label except indicator
        scrollView.subviews.forEach({
            if $0 !== indicator {
                $0.removeFromSuperview()
            }
        })
        
        
        let titles = self.dataSource.scrollMenuTitles()
        let height = CGRectGetHeight(self.bounds)
        
        var currentX = leftInset
        
        for (index,title) in titles.enumerate() {
            let sizeTitle = calculateSizeForString(title, font: font)
            let frameTitle = CGRectMake(currentX, 0, sizeTitle.width, height)
            let gesture = UITapGestureRecognizer(target: self, action: #selector(tapBySelectItem(_:)))
            gesture.numberOfTapsRequired = 1
            let label = ScrollMenuLabel(frame: frameTitle,
                                        gesture: gesture)
            label.tag = kTagLabel + index
            label.font = font
            label.textColor = color
            label.text = title
            
            
            self.scrollView.addSubview(label)
            if index == currentIndex {
                indicator.frame = CGRectMake(currentX, indicator.frame.origin.y, CGRectGetWidth(frameTitle), indicator.frame.size.height)
                label.textColor = selectedColor
            }
            currentX += (CGRectGetWidth(frameTitle) + spacingItem)
        }
        

        let sizeScrollView = CGSizeMake(currentX - spacingItem + rightInset, height)
        scrollView.contentSize = sizeScrollView
        
    }
    
    func tapBySelectItem(sender:UITapGestureRecognizer){
        guard let view = sender.view as? UILabel else{
            return
        }
        
        if view.tag - kTagLabel != currentIndex {
            self.delegate?.scrollMenuDidSelectAtIndex?(self, index: view.tag - kTagLabel)
        }
        
        self.selectItemWithAnimation(view.tag - kTagLabel, animate: true)
        
    }
    
    override func removeFromSuperview() {
        self.scrollView.contentOffset = CGPointZero
        super.removeFromSuperview()
    }
    
    deinit{
         print("\(#function) class:\(self.dynamicType)")
    }
    
}
// MARK: --- Helper
func calculateSizeForString(text:String,font:UIFont,maxWidth:CGFloat = CGFloat.max, maxHeight:CGFloat = CGFloat.max) -> CGSize
{
    let constraintRect = CGSize(width: maxWidth, height: maxHeight)
    
    let boundingBox = text.boundingRectWithSize(constraintRect,
                                                options: [.UsesFontLeading,.UsesLineFragmentOrigin],
                                                attributes: [NSFontAttributeName: font],
                                                context: nil)
    
    return boundingBox.size
}

// MARK: --- Public Function
extension ScrollMenuView{
    
    func selectItemWithAnimation(index:Int,animate:Bool)
    {
        
        guard let viewSelect = scrollView.viewWithTag(index + kTagLabel) else{
            return
        }
        currentIndex = index
       
        let currentWidth = self.scrollView.contentOffset.x + self.bounds.width
        let needMove = viewSelect.frame.origin.x + viewSelect.frame.size.width > currentWidth || viewSelect.frame.origin.x < self.scrollView.contentOffset.x
        
        let spacing = self.dataSource.scrollMenuSpacingForItem()
        
        let color = self.dataSource.scrollMenuColorTitle()
        let selectedColor = self.dataSource.scrollMenuColorForSelectedItem()
        
        scrollView.subviews.forEach {
            if let label = $0 as? UILabel {
                if label === viewSelect {
                    label.textColor = selectedColor
                }else{
                    label.textColor = color
                }
            }
        }
        
        let frame = viewSelect.frame
        
        var newFrameIndicator = self.indicator.frame
        newFrameIndicator.size.width = frame.width
        newFrameIndicator.origin.x = frame.origin.x
        
        UIView.animateWithDuration(animate ? 0.3 : 0, animations: { [weak self] in
            self?.indicator.frame = newFrameIndicator
            if needMove{
                self?.scrollView.contentOffset = CGPointMake(viewSelect.frame.origin.x - spacing, 0)
            }
        }) { _ in
            print("Animation Complete!!!")
        }
    }
}
