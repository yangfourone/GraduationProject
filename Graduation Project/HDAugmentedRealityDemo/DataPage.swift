//
//  DataPage.swift
//  HDAugmentedRealityDemo
//
//  Created by MITLAB on 2017/9/16.
//  Copyright © 2017年 Danijel Huis. All rights reserved.
//

import UIKit

class DataPage: UIViewController {
    
    @IBOutlet weak var ShowRegion: UILabel!
    @IBOutlet weak var ShowFloor: UILabel!
    
    var FloorData:String?
    var RegionData:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ShowFloor.text = FloorData
        self.ShowRegion.text = RegionData
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
