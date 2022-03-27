//
//  ManageKegController.swift
//  OtterKeg
//
//  Created by Hanwen Xu on 9/3/21.
//

import UIKit
import Firebase

final class ManageKegController: UIViewController{
    
    @IBOutlet weak var whichKegLabel: UILabel!
    @IBOutlet weak var kegPickerView: UIPickerView!
    
    @IBOutlet weak var whichBeerLabel: UILabel!
    @IBOutlet weak var beerPickerView: UIPickerView!
    @IBOutlet weak var beerIDLabel: UILabel!
    @IBOutlet weak var beerIdTextField: UITextField!
    
    @IBOutlet weak var changeKegButton: UIButton!

    
    @IBOutlet weak var manageKegsTitle: UILabel!
    
    var kegsArray = [Keg]()
    private var activeKegsArray = [Keg]()

    var beersDict = [String: Beer]()
    var beersArray = [Beer]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //UI Setup
        manageKegsTitle.text = "Kegs"
        setupChangeKegButton()
        
        //Data Setup
        setupData()
    }
    
    func setupData() {
        OtterKegFirebase.sharedFirebase.getBeers(onError: nil, onCompletion: { beers in
            self.beersDict = beers
            self.beersArray = Array(beers.values.map{$0})
            self.beersArray = self.beersArray.sorted(by: {$0.nameDeprecated < $1.nameDeprecated} )
            DispatchQueue.main.async {
                self.kegPickerView.reloadAllComponents()
                self.beerPickerView.reloadAllComponents()
                self.setBeerIDLabel(forBeer: self.beersArray[0])
            }
        })

        OtterKegFirebase.sharedFirebase.getKegs(onError: nil, onCompletion: { kegs in
            self.kegsArray = Array(kegs.values.map{$0})
            self.kegsArray = self.kegsArray.sorted(by: {$0.position < $1.position} )
            self.activeKegsArray = self.kegsArray.filter( {$0.isActive} )
            DispatchQueue.main.async {
                self.kegPickerView.reloadAllComponents()
            }
        })
    }

}

extension ManageKegController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        var numComps = 1
        
        if pickerView == kegPickerView {
            numComps = 1
        } else if pickerView == beerPickerView {
            numComps = 1
        }
        
        return numComps
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var numRows = 0
        
        if pickerView == kegPickerView {
            numRows = self.activeKegsArray.count
        } else if pickerView == beerPickerView {
            numRows = self.beersArray.count
        }
        
        return numRows
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var rowName = "uhhhh"

        if pickerView == kegPickerView {
            let keg = self.activeKegsArray[row]
            rowName = String(format:"%@ - %@", keg.position, self.beersDict[keg.beerId]?.nameDeprecated ?? "Unknown Beer")
        } else if pickerView == beerPickerView {
            let beer = self.beersArray[row]
            rowName = String(format:"%@ - %@", beer.nameDeprecated, String(format: "%.0f", beer.untappedBid))
            
            return NSAttributedString(string: rowName, attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        }
        
        return NSAttributedString(string: rowName, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == kegPickerView {
            let keg = activeKegsArray[row]
            let rowName = String(format:"%@ - %@", keg.position, self.beersDict[keg.beerId]?.nameDeprecated ?? "Unknown Beer")
            print("Keg \"\(rowName)\" selected")
        } else if pickerView == beerPickerView {
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
        changeKegButton.layer.cornerRadius = 5
        changeKegButton.setTitle("Swap", for: .normal)
        
        enableChangeKegButton()
    }
    
    func disableChangeKegButton() {
        changeKegButton.backgroundColor = UIColor.systemGray
        changeKegButton.isEnabled = false
    }
    
    func enableChangeKegButton() {
        changeKegButton.backgroundColor = UIColor.systemBlue
        changeKegButton.isEnabled = true
    }
    
    func setBeerIDLabel(forBeer beer: Beer) {
        beerIdTextField.textColor = .black
        beerIdTextField.text = String(format: "%.0f", beer.untappedBid)
    }
}

