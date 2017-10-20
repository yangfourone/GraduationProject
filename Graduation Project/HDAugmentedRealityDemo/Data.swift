//
//  Data.swift
//  Beacon
//
//  Created by MITLAB on 2017/3/1.
//  Copyright © 2017年 MITLAB. All rights reserved.
//

import UIKit

class Data: UIViewController {
    
    @IBOutlet weak var ShowFloor :UITextField!
    @IBOutlet weak var ShowRegion :UITextField!
    

    
    var FloorData:String?
    var RegionData:String?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.ShowFloor.text = FloorData
       // self.ShowRegion.text = RegionData
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
