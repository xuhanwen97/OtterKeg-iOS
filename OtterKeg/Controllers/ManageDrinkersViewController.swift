//
//  ManageDrinkersViewController.swift
//  OtterKeg
//
//  Created by Hanwen Xu on 3/27/22.
//

import UIKit

class ManageDrinkerViewController: UIViewController {

    @IBOutlet var drinkerTableView: UITableView!
    
    var drinkersDict = [String : Drinker]()
    var drinkersArray = [Drinker]()
    var pours = [Pour]()
    var totalPoursForDrinkers = [Drinker : Double]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupData()
        
        self.navigationItem.title = "Drinkers"
        
        setupNavBar()
        setupDrinkerTableView()
    }
    
}


// UI elements helper functions
extension ManageDrinkerViewController {
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
        
        let addDrinkerButton = UIBarButtonItem(title: "Add Drinker", style: .plain, target: self, action: #selector(addDrinkerButtonTapped))
        addDrinkerButton.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        
        navigationItem.rightBarButtonItem = addDrinkerButton
        
    }
    
    func setupDrinkerTableView() {
        self.drinkerTableView.showsVerticalScrollIndicator = false
        self.drinkerTableView.separatorColor = .lightGray
        self.drinkerTableView.separatorInset = .zero
        self.drinkerTableView.backgroundColor = ColorConstants.otterKegBackground
    }
}


// TableViewController Functions
extension ManageDrinkerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.drinkersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DrinkerCell", for: indexPath) as! DrinkerTableViewCell
        
        let drinker = self.drinkersArray[indexPath.row]
        
        cell.drinkerLabel.text = drinker.name
        
        var amountText = "0.0 Pints"
        if let amount = totalPoursForDrinkers[drinker] {
            amountText = String(format:"%0.2f Pints", amount * 2.11338)
        }
        cell.amountLabel.text = amountText

        return cell
    }
}

// Data helper functions
extension ManageDrinkerViewController {
    func setupData() {
        OtterKegFirebase.sharedFirebase.getDrinkers(onError: nil, onCompletion: { drinkers in
            
            self.drinkersDict = drinkers
            
            self.buildTotalPoursDict()
           
            DispatchQueue.main.async {
                self.drinkerTableView.reloadData()
            }
        })
        
        OtterKegFirebase.sharedFirebase.getPours(onError: nil, onCompletion: { pours in
            self.pours = pours
            
            self.buildTotalPoursDict()
            
            DispatchQueue.main.async {
                self.drinkerTableView.reloadData()
            }
        })
    }
    
    func buildTotalPoursDict() {
        for drinker in self.drinkersDict.values {
            self.totalPoursForDrinkers[drinker] = 0.0
        }
        
        getTotalPoursForEachDrinker()
        orderDrinkers()
    }
    
    func getTotalPoursForEachDrinker() {
        for pour in self.pours {
            if let drinker = drinkersDict[pour.drinkerId] {
                let existingValue = totalPoursForDrinkers[drinker] ?? 0.0
                totalPoursForDrinkers[drinker] = existingValue + pour.amount
            } else {
                print("Bad Drinker ID")
            }
        }
        
        print(totalPoursForDrinkers)
    }
    
    func orderDrinkers() {
        self.drinkersArray = Array(self.drinkersDict.values.map{$0})
        self.drinkersArray = self.drinkersArray.sorted(by: {self.totalPoursForDrinkers[$0] ?? 0 > self.totalPoursForDrinkers[$1] ?? 0} )
    }
}


// Navigation helper functions
extension ManageDrinkerViewController {
    @objc func addDrinkerButtonTapped() {
        print("add drinker")
    }
}
