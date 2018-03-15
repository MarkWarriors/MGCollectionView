//
//  ViewController.swift
//  MGCollectionView
//
//  Created by Marco Guerrieri on 11/03/18.
//  Copyright © 2018 Marco Guerrieri. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var iphonePortraitRowNumberLbl: UITextField!
    @IBOutlet weak var iphoneLandscapeRowNumberLbl: UITextField!
    @IBOutlet weak var ipadPortraitRowNumberLbl: UITextField!
    @IBOutlet weak var ipadLandscapeRowNumberLbl: UITextField!
    @IBOutlet weak var cellProportionWidth: UITextField!
    @IBOutlet weak var cellProportionHeight: UITextField!
    @IBOutlet weak var cellSpacingLeft: UITextField!
    @IBOutlet weak var cellSpacingRight: UITextField!
    @IBOutlet weak var cellSpacingTop: UITextField!
    @IBOutlet weak var cellSpacingBottom: UITextField!
    @IBOutlet weak var pullToRefreshSwitch: UISwitch!
    @IBOutlet weak var infiniteScrollSwitch: UISwitch!
    @IBOutlet weak var dataFromInternetSwitch: UISwitch!
    
    private var currentEditingTF : UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        closeKeyboardIfViewIsTapped(view: self.view)
    }

    public func closeKeyboardIfViewIsTapped(view: UIView) {
        view.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(self.dismissKeyboard)))
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        for v in self.view.subviews{
            if v is UITextField && (v as! UITextField).text == ""{
                (v as! UITextField).text = "0"
            }
        }
        
        if segue.identifier == "toMgCollectionView" {
            let dst = segue.destination as! CollectionViewController
            dst.cellForRow = (
                (iphonePortraitRowNumberLbl.text! as NSString).integerValue,
                (iphoneLandscapeRowNumberLbl.text! as NSString).integerValue,
                (ipadPortraitRowNumberLbl.text! as NSString).integerValue,
                (ipadLandscapeRowNumberLbl.text! as NSString).integerValue
            )
            
            dst.cellProportion = CGSize.init(
                width: (cellProportionWidth.text! as NSString).integerValue,
                height: (cellProportionHeight.text! as NSString).integerValue
            )
            
            dst.cellSpacing = (
                left: CGFloat((cellSpacingLeft.text! as NSString).floatValue),
                top: CGFloat((cellSpacingTop.text! as NSString).floatValue),
                right: CGFloat((cellSpacingRight.text! as NSString).floatValue),
                bottom: CGFloat((cellSpacingBottom.text! as NSString).floatValue)
            )
            
            dst.usePullToRefresh = pullToRefreshSwitch.isOn
            dst.useInfiniteScroll = infiniteScrollSwitch.isOn
            dst.testWithRequest = dataFromInternetSwitch.isOn
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 2
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.currentEditingTF = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if self.currentEditingTF?.text == "" {
            self.currentEditingTF?.text = "0"
        }
        self.currentEditingTF = nil
    }
    

    @objc public func dismissKeyboard(){
        self.view.endEditing(true)
        self.currentEditingTF?.resignFirstResponder()
    }
}

