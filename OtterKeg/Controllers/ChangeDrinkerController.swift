//
//  DrinkerPickerController.swift
//  OtterKeg
//
//  Created by Hanwen Xu on 3/6/21.
//

import UIKit
import Firebase


final class ChangeDrinkerController: UIViewController{
    
    @IBOutlet var DrinkerPicker: UIPickerView!
    @IBOutlet weak var ChangeDrinkerButton: UIButton!
    @IBOutlet weak var CurrentDrinkerLabel: UILabel!
    
    var drinkers = [Drinker]()
    
    var originalSelectedPour: Pour? = nil
    var originalSelectedDrinker: Drinker? = nil

    private var selectedDrinker: Drinker? = nil
    
    override func viewDidLoad() {
        ChangeDrinkerButton.backgroundColor = UIColor.systemBlue
        ChangeDrinkerButton.layer.cornerRadius = 5
        
        guard let originalSelectedDrinkerPosition = drinkers.firstIndex(where: {$0.name == originalSelectedDrinker?.name})
        else {
            print("something's wrong, there should always be a selected drinker")
            return
        }
        
        CurrentDrinkerLabel.text = "Currently Poured For: \(originalSelectedDrinker?.name ?? "Unknown Drinker")"
        
        DrinkerPicker.selectRow(originalSelectedDrinkerPosition, inComponent: 0, animated: true)
        disableChangeDrinkerButton()
    }
    
    @IBAction func ChangeDrinkerButtonPressed(_ sender: Any) {
        print("\(selectedDrinker?.name ?? "Oops") selected as new drinker")
        
        updateDrinkerForPour()
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
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedDrinker = drinkers[row]
        
        if selectedDrinker?.name == originalSelectedDrinker?.name {
            disableChangeDrinkerButton()
        } else {
            enableChangeDrinkerButton()
        }
    }
    
    func updateDrinkerForPour() {
        guard let pour = originalSelectedPour else { print("Error: There should always be an original selected pour"); return; }
        guard let newDrinker = selectedDrinker else { print("Error: There should always be a newly selected drinker"); return; }

        if newDrinker.name == originalSelectedDrinker?.name {
            print("Error: Do not update if the drinker hasn't changed")
            return
        }
        
        let poursRef = Database.database().reference(withPath: "pours")
        poursRef.child(pour.key).updateChildValues(["drinkerId": newDrinker.key])
        
        dismiss(animated: true) {
            print("picker dismissed")
        }
        
    }
}

// UI elements helper functions
extension ChangeDrinkerController {
    func disableChangeDrinkerButton() {
        ChangeDrinkerButton.backgroundColor = UIColor.systemGray
        ChangeDrinkerButton.isEnabled = false
    }
    
    func enableChangeDrinkerButton() {
        ChangeDrinkerButton.backgroundColor = UIColor.systemBlue
        ChangeDrinkerButton.isEnabled = true
    }
}
