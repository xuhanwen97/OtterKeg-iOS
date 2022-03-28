//
//  ManageDrinkersViewController.swift
//  OtterKeg
//
//  Created by Hanwen Xu on 3/27/22.
//

import UIKit

class ManageDrinkerViewController: UIViewController {

    @IBOutlet var drinkerTableView: UITableView!
    
    var drinkersDict = [String: Drinker]()
    var drinkersArray = [Drinker]()
    var pours = [Pour]()

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

        return cell
    }
}

// Data helper functions
extension ManageDrinkerViewController {
    func setupData() {
        OtterKegFirebase.sharedFirebase.getDrinkers(onError: nil, onCompletion: { drinkers in
            self.drinkersDict = drinkers
            self.drinkersArray = Array(drinkers.values.map{$0})
            self.drinkersArray = self.drinkersArray.sorted(by: {$0.name < $1.name} )
           
            DispatchQueue.main.async {
                self.drinkerTableView.reloadData()
            }
        })
        
        OtterKegFirebase.sharedFirebase.getPours(onError: nil, onCompletion: { pours in
            self.pours = pours
            
            DispatchQueue.main.async {
                self.drinkerTableView.reloadData()
            }
        })
    }
}
