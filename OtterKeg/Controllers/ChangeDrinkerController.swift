//
//  DrinkerPickerController.swift
//  OtterKeg
//
//  Created by Hanwen Xu on 3/6/21.
//

import UIKit

final class ChangeDrinkerController: UIViewController{
    
    @IBOutlet var DrinkerPicker: UIPickerView!
    @IBOutlet weak var ChangeDrinkerButton: UIButton!
    
    var drinkers = [Drinker]()
    
    override func viewDidLoad() {
        ChangeDrinkerButton.backgroundColor = UIColor.systemBlue
        ChangeDrinkerButton.layer.cornerRadius = 5
    }
    
}

extension ChangeDrinkerController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return drinkers.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return drinkers[row].name
    }
}
