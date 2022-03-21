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
    var kegs = [String: Keg]()
    var beers = [String: Beer]()
    
    private var activeKegs = [String: Keg]()
    
    
    
    override func viewDidLoad() {
        activeKegs = kegs.filter( {$0.value.isActive} )
        print(activeKegs)
        manageKegsTitle.text = "Kegs"
    }

}

extension ManageKegController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 1
    }
    

}


// UI elements helper functions
extension ManageKegController {
    func disableChangeKegButton() {
        ChangeKegButton.backgroundColor = UIColor.systemGray
        ChangeKegButton.isEnabled = false
    }
    
    func enableChangeKegButton() {
        ChangeKegButton.backgroundColor = UIColor.systemBlue
        ChangeKegButton.isEnabled = true
    }
}

