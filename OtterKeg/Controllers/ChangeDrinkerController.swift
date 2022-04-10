//
//  DrinkerPickerController.swift
//  OtterKeg
//
//  Created by Hanwen Xu on 3/6/21.
//

import UIKit
import Firebase


final class ChangeDrinkerController: UIViewController{
    
    @IBOutlet var drinkerPickerView: UIPickerView!
    @IBOutlet weak var changeDrinkerButton: UIButton!
    @IBOutlet weak var currentDrinkerLabel: UILabel!
    
    var drinkers = [Drinker]()
    
    var originalSelectedPour: Pour? = nil
    var originalSelectedDrinker: Drinker? = nil

    private var selectedDrinker: Drinker? = nil
    
    override func viewDidLoad() {
        changeDrinkerButton.backgroundColor = UIColor.systemBlue
        changeDrinkerButton.layer.cornerRadius = 5
        
        guard let originalSelectedDrinkerPosition = drinkers.firstIndex(where: {$0.name == originalSelectedDrinker?.name})
        else {
            print("something's wrong, there should always be a selected drinker")
            return
        }
        
        currentDrinkerLabel.text = "Currently Poured For: \(originalSelectedDrinker?.name ?? "Unknown Drinker")"
        
        drinkerPickerView.selectRow(originalSelectedDrinkerPosition, inComponent: 0, animated: true)
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
    
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: String(format:"%@ - %@", drinkers[row].name, drinkers[row].userStatus), attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedDrinker = drinkers[row]
        
        if selectedDrinker?.name == originalSelectedDrinker?.name {
            disableChangeDrinkerButton()
        } else {
            enableChangeDrinkerButton()
        }
    }

}

// Change drinker helper function
extension ChangeDrinkerController {
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
        changeDrinkerButton.backgroundColor = UIColor.systemGray
        changeDrinkerButton.isEnabled = false
    }
    
    func enableChangeDrinkerButton() {
        changeDrinkerButton.backgroundColor = UIColor.systemBlue
        changeDrinkerButton.isEnabled = true
    }
}
