//
//  ManageKegController.swift
//  OtterKeg
//
//  Created by Hanwen Xu on 9/3/21.
//

import UIKit
import Firebase

final class ManageKegController: UIViewController {
    
    @IBOutlet weak var whichKegLabel: UILabel!
    @IBOutlet weak var kegPickerView: UIPickerView!
    
    @IBOutlet weak var whichBeerLabel: UILabel!
    @IBOutlet weak var beerPickerView: UIPickerView!
    
    @IBOutlet weak var beerNameLabel: UILabel!
    @IBOutlet weak var beerNameTextField: UITextField!
    @IBAction func beerNameTextFieldOnEditingChanged(_ sender: Any) { setChangeKegButtonState() }
    
    @IBOutlet weak var beerIdLabel: UILabel!
    @IBOutlet weak var beerIdTextField: UITextField!
    @IBAction func beerIdTextFieldOnEditingChanged(_ sender: Any) { setChangeKegButtonState() }
    
    @IBOutlet weak var kegVolumeLabel: UILabel!
    @IBOutlet weak var kegVolumeTextField: UITextField!
    @IBAction func kegVolumeTextFieldOnEditingChanged(_ sender: Any) { setChangeKegButtonState() }
    
    @IBOutlet weak var changeKegButton: UIButton!
    @IBAction func changeKegButtonOnTouchUp(_ sender: Any) {
        changeKegButtonSelected()
    }
    
    var kegsArray = [Keg]()
    private var activeKegsArray = [Keg]()

    var beersDict = [String: Beer]()
    var beersArray = [Beer]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Data Setup
        setupData()
        
        //UI Setup
        self.navigationItem.title = "Kegs"
        
        setupNavBar()
        setupChangeKegButton()
        setupKegBeerDetailTextFields()
    }
}

// UI elements helper functions
extension ManageKegController {
    func setupNavBar() {
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            navBarAppearance.backgroundColor = ColorConstants.otterKegBackground
            
            self.navigationController?.navigationBar.standardAppearance = navBarAppearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance

            navigationController?.navigationBar.prefersLargeTitles = true
        }
    }
}

// Picker View Helper Functions
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
            setLabelsForSelectedBeer(forBeer: beer)
            print("Beer \"\(rowName)\" selected")
        }
    }
}


// UI elements helper functions
extension ManageKegController {
    func setupChangeKegButton() {
        changeKegButton.layer.cornerRadius = 5
        changeKegButton.setTitle("Swap", for: .normal)
        
        setChangeKegButtonState()
    }
    
    func setupKegBeerDetailTextFields() {
        beerNameTextField.placeholder = "Beer Name"
        
        beerIdTextField.keyboardType = .numberPad
        beerIdTextField.placeholder = "Untappd Beer ID"
                
        kegVolumeTextField.keyboardType = .numberPad
        kegVolumeTextField.text = "41"
        kegVolumeTextField.placeholder = "Default: 41"
    }
    
    func setChangeKegButtonState() {
        if beerIdTextField.text?.count == 0 ||
            beerNameTextField.text?.count == 0 ||
            kegVolumeTextField.text?.count == 0
        {
            disableChangeKegButton()
        } else {
            enableChangeKegButton()
        }
    }
    
    func disableChangeKegButton() {
        changeKegButton.backgroundColor = UIColor.systemGray
        changeKegButton.isEnabled = false
    }
    
    func enableChangeKegButton() {
        changeKegButton.backgroundColor = UIColor.systemBlue
        changeKegButton.isEnabled = true
    }
    
    func changeKegButtonSelected() {
        // The button status is set based on the two required text fields, so this is a lazy man's error check.
        if !changeKegButton.isEnabled {
            print("change keg button is not enabled, cannot change kegs")
            return
        }
        
        let selectedExistingKeg = activeKegsArray[kegPickerView.selectedRow(inComponent: 0)]
        
        if let newKegUntappdBid = beerIdTextField.text {
            if let newKegNameDeprecated = beerNameTextField.text {
                if !newKegUntappdBid.isEmpty && !newKegNameDeprecated.isEmpty {
                    OtterKegFirebase.sharedFirebase.swapKegs(existingKeg: selectedExistingKeg, newNameDeprecated: newKegNameDeprecated, newUntappdBid: Double(newKegUntappdBid) ?? 0, onError: nil, onCompletion: {
                        print("Kegs swapped successfully!")
                        self.setupData()
                    })
                    return
                }
            }
        }
        
        //Should not get here, if it does, something failed
        print("Swapping Kegs failed, no Untappd Beer ID")
    }
    
    func setLabelsForSelectedBeer(forBeer beer: Beer) {
        beerNameTextField.textColor = .black
        beerNameTextField.text = String(beer.nameDeprecated)
        
        beerIdTextField.textColor = .black
        beerIdTextField.text = String(format: "%.0f", beer.untappedBid)
        
        setChangeKegButtonState()
    }
}

// Data helper functions
extension ManageKegController {
    func setupData() {
        OtterKegFirebase.sharedFirebase.getBeers(onError: nil, onCompletion: { beers in
            self.beersDict = beers
            self.beersArray = Array(beers.values.map{$0})
            self.beersArray = self.beersArray.sorted(by: {$0.nameDeprecated < $1.nameDeprecated} )
            DispatchQueue.main.async {
                self.kegPickerView.reloadAllComponents()
                self.beerPickerView.reloadAllComponents()
                self.setLabelsForSelectedBeer(forBeer: self.beersArray[0])
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
