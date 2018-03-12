//
//  ViewController.swift
//  MGCollectionView
//
//  Created by Marco Guerrieri on 11/03/18.
//  Copyright © 2018 Marco Guerrieri. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var iphonePortraitRowNumberLbl: MGTextField!
    @IBOutlet weak var iphoneLandscapeRowNumberLbl: MGTextField!
    @IBOutlet weak var ipadPortraitRowNumberLbl: MGTextField!
    @IBOutlet weak var ipadLandscapeRowNumberLbl: MGTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMgCollectionView" {
            let dst = segue.destination as! CollectionViewController
            dst.cellForRow = (
                (iphonePortraitRowNumberLbl.text! as NSString).integerValue,
                (iphoneLandscapeRowNumberLbl.text! as NSString).integerValue,
                (ipadPortraitRowNumberLbl.text! as NSString).integerValue,
                (ipadLandscapeRowNumberLbl.text! as NSString).integerValue
            )
        }
    }
    

}

