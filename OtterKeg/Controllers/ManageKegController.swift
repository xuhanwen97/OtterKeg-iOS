//
//  ManageKegController.swift
//  OtterKeg
//
//  Created by Hanwen Xu on 9/3/21.
//

import UIKit
import Firebase

final class ManageKegController: UIViewController{
    
    @IBOutlet weak var WhichKegLabel: UILabel!
    @IBOutlet weak var KegPicker: UIPickerView!
    
    @IBOutlet weak var WhichBeerLabel: UILabel!
    @IBOutlet weak var BeerPicker: UIPickerView!
    @IBOutlet weak var BeerIDLabel: UILabel!
    @IBOutlet weak var BeerIdTextField: UITextField!
    
    @IBOutlet weak var ChangeKegButton: UIButton!

    
    @IBOutlet weak var manageKegsTitle: UILabel!
    
    var kegsArray = [Keg]()
    var beersDict = [String: Beer]()
    var beersArray = [Beer]()
    private var activeKegsArray = [Keg]()
    
    override func viewDidLoad() {
        manageKegsTitle.text = "Kegs"
        setupChangeKegButton()
        
        OtterKegFirebase.sharedFirebase.getBeers(onError: nil, onCompletion: { beers in
            self.beersDict = beers
            self.beersArray = Array(beers.values.map{$0})
            self.beersArray = self.beersArray.sorted(by: {$0.nameDeprecated < $1.nameDeprecated} )
            DispatchQueue.main.async {
                self.KegPicker.reloadAllComponents()
                self.BeerPicker.reloadAllComponents()
                self.setBeerIDLabel(forBeer: self.beersArray[0])
            }
        })

        OtterKegFirebase.sharedFirebase.getKegs(onError: nil, onCompletion: { kegs in
            self.kegsArray = Array(kegs.values.map{$0})
            self.kegsArray = self.kegsArray.sorted(by: {$0.position < $1.position} )
            self.activeKegsArray = self.kegsArray.filter( {$0.isActive} )
            DispatchQueue.main.async {
                self.KegPicker.reloadAllComponents()
            }
        })
    }

}

extension ManageKegController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        var numComps = 1
        
        if pickerView == KegPicker {
            numComps = 1
        } else if pickerView == BeerPicker {
            numComps = 1
        }
        
        return numComps
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var numRows = 0
        
        if pickerView == KegPicker {
            numRows = self.activeKegsArray.count
        } else if pickerView == BeerPicker {
            numRows = self.beersArray.count
        }
        
        return numRows
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var rowName = "uhhhh"

        if pickerView == KegPicker {
            let keg = self.activeKegsArray[row]
            rowName = String(format:"%@ - %@", keg.position, self.beersDict[keg.beerId]?.nameDeprecated ?? "Unknown Beer")
        } else if pickerView == BeerPicker {
            let beer = self.beersArray[row]
            rowName = String(format:"%@ - %@", beer.nameDeprecated, String(format: "%.0f", beer.untappedBid))
            
            return NSAttributedString(string: rowName, attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        }
        
        return NSAttributedString(string: rowName, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == KegPicker {
            let keg = activeKegsArray[row]
            let rowName = String(format:"%@ - %@", keg.position, self.beersDict[keg.beerId]?.nameDeprecated ?? "Unknown Beer")
            print("Keg \"\(rowName)\" selected")
        } else if pickerView == BeerPicker {
            let beer = beersArray[row]
            let rowName = String(format:"%@ - %@", beer.nameDeprecated, String(format: "%.0f", beer.untappedBid))
            setBeerIDLabel(forBeer: beer)
            print("Beer \"\(rowName)\" selected")
        }
    }
    
}


// UI elements helper functions
extension ManageKegController {
    func setupChangeKegButton() {
        ChangeKegButton.layer.cornerRadius = 5
        ChangeKegButton.setTitle("Swap", for: .normal)
        
        enableChangeKegButton()
    }
    
    func disableChangeKegButton() {
        ChangeKegButton.backgroundColor = UIColor.systemGray
        ChangeKegButton.isEnabled = false
    }
    
    func enableChangeKegButton() {
        ChangeKegButton.backgroundColor = UIColor.systemBlue
        ChangeKegButton.isEnabled = true
    }
    
    func setBeerIDLabel(forBeer beer: Beer) {
        BeerIdTextField.text = String(format: "%.0f", beer.untappedBid)
    }
}

