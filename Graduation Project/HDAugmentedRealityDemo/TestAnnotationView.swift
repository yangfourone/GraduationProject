//
//  TestAnnotationView.swift
//  HDAugmentedRealityDemo
//
//  Created by Danijel Huis on 30/04/15.
//  Copyright (c) 2015 Danijel Huis. All rights reserved.
//

import UIKit

open class TestAnnotationView: ARAnnotationView, UIGestureRecognizerDelegate
{
    open var titleLabel: UILabel?
    open var infoButton: UIButton?
    open var viewShow: UIView!
    open var imageShow: UIImageView?
    
    var Anota:ARAnnotation!
    
    override open func didMoveToSuperview()
    {
        super.didMoveToSuperview()
        if self.titleLabel == nil
        {
            self.loadUi()
        }
    }
    
    func loadUi()
    {
        // Title label
        self.titleLabel?.removeFromSuperview()
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10) //訊息框文字大小
        label.numberOfLines = 0 //訊息框可顯示幾行文字（0：全顯）
        label.backgroundColor = UIColor.black //訊息框中間部份顏色
        label.textColor = UIColor.yellow //訊息框訊息顏色
        self.addSubview(label)
        self.titleLabel = label
        
        // Info button
        self.infoButton?.removeFromSuperview()
        let button = UIButton(type: UIButtonType.detailDisclosure)
        button.isUserInteractionEnabled = false   // Whole view will be tappable, using it for appearance
        self.addSubview(button)
        self.infoButton = button
        
        // Gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(TestAnnotationView.tapGesture))
        self.addGestureRecognizer(tapGesture)
        
        // Other
        self.backgroundColor = UIColor.black  //.withAlphaComponent(0.5)
        //------------------------訊息框兩邊顏色------漸層度-----------
        self.layer.cornerRadius = 5
        
        if self.annotation != nil
        {
            self.bindUi()
        }
    }
    
    func layoutUi()
    {
        let buttonWidth: CGFloat = 40
        let buttonHeight: CGFloat = 40
        
        //imageshow 位置與大小
        self.imageShow?.frame = CGRect(x: 0, y: 600, width: 132, height: 132)
        
        self.titleLabel?.frame = CGRect(x: 10, y: 0, width: self.frame.size.width - buttonWidth - 5, height: self.frame.size.height);
        self.infoButton?.frame = CGRect(x: self.frame.size.width - buttonWidth, y: self.frame.size.height/2 - buttonHeight/2, width: buttonWidth, height: buttonHeight);
    }
    
    // This method is called whenever distance/azimuth is set
    override open func bindUi()
    {
        if let annotation = self.annotation, let title = annotation.title
        {
            let distance = annotation.distanceFromUser > 1000 ? String(format: "%.1fkm", annotation.distanceFromUser / 1000) : String(format:"%.0fm", annotation.distanceFromUser)
            //判斷有沒有超過1公里，有的話用km顯示，沒有的話用m顯示
            let text = String(format: "%@\nAZ: %.0f°\nDST: %@", title, annotation.azimuth, distance)
            self.titleLabel?.text = text
        }
    }
    
    open override func layoutSubviews()
    {
        super.layoutSubviews()
        self.layoutUi()
    }
    
    //訊息框
    
    open func tapGesture()
    {
        if let annotation = self.annotation
        {
            let alertView = UIAlertController(title: annotation.title , message: "Continous or look the picture", preferredStyle: .alert)
            
            //let cancel = UIAlertAction(title: "NO", style: .cancel, handler: nil)
            //alertView.addAction(cancel)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertView.addAction(ok)
            let picture = UIAlertAction(title: "Picture", style: .destructive, handler: {
                action in
                self.showPicture()
            })
            alertView.addAction(picture)
            
            UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.present(alertView, animated: true, completion: nil)
            // alertView.show()
        }
    }
 
    
    
    func showPicture() {
        
        var search:String!
        
        let alertViewwithName = UIAlertController(title: annotation?.title, message: "Do you want to use this keyword for Searching? or enter other name", preferredStyle: .alert)
        
        
        //add a textfield on alertView
        alertViewwithName.addTextField(configurationHandler:
            {
                textfield in
                textfield.placeholder = "test"
                textfield.text = (self.annotation?.title)!
        }
        )
        let sure = UIAlertAction(title: "繼續", style: UIAlertActionStyle.default,   handler:
        {
                action in // when continue encode the text and then search online
            
                //get the text value from the textfield on alertview
                search = "http://www.s-super.com/super/ntustbuilding" + (self.annotation?.title)!
                //search = "http://www.google.com/search?q=台科 " + (self.annotation?.title)! + " 圖片"
                search = search.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
                let url = URL(string: search)
                UIApplication.shared.open(url!)
            }
        )
        alertViewwithName.addAction(sure)
            
        UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.present(alertViewwithName, animated: true, completion: nil)
            
        
    }


}
