//
//  ViewController.swift
//  OtterKeg
//
//  Created by Hanwen Xu on 2/26/21.
//

import UIKit
import Firebase

class ManagePoursViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var poursTableView: UITableView!
    
    var pours: [Pour] = []
    let poursRef = Database.database().reference(withPath: "pours")
    
    var drinkers = [String: Drinker]()
    let drinkersRef = Database.database().reference(withPath: "drinkers")
    
    var kegs = [String: Keg]()
    let kegsRef = Database.database().reference(withPath: "kegs")
    
    var beers = [String: Beer]()
    let beersRef = Database.database().reference(withPath: "beers")
    
    var selectedPour: Pour? = nil
    var selectedDrinker: Drinker? = nil
    
    lazy var slideInTransitioningDelegate = SlideInPresentationManager()

    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupData()

        self.navigationItem.title = "Pours"
        
        setupNavBar()
        setupPoursTableView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ChangeDrinkerSegue" {
            if let controller = segue.destination as? ChangeDrinkerController {
                slideInTransitioningDelegate.direction = .bottom
                slideInTransitioningDelegate.disableCompactHeight = true
                
                controller.transitioningDelegate = slideInTransitioningDelegate
                controller.modalPresentationStyle = .custom
                
                
                controller.drinkers = Array(self.drinkers.values).sorted(by: { $0.name < $1.name })
                controller.originalSelectedPour = self.selectedPour
                controller.originalSelectedDrinker = self.selectedDrinker
                
                // Clear the selected drinker after sending it over to the segue
                
                self.selectedPour = nil
                self.selectedDrinker = nil
            }
        }
    }
    
}

// UI elements helper functions
extension ManagePoursViewController {
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
    
    func setupPoursTableView() {
        self.poursTableView.showsVerticalScrollIndicator = false
        self.poursTableView.separatorColor = .lightGray
        self.poursTableView.separatorInset = .zero
        self.poursTableView.backgroundColor = ColorConstants.otterKegBackground
    }
}


// TableViewController Functions
extension ManagePoursViewController {
    // Table View Controllers
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pours.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PourCell", for: indexPath) as! PourTableViewCell
        let pour = pours[indexPath.row]
        
        let drinkerName = String(self.drinkers[pour.drinkerId]?.name ?? "Unknown Drinker")
        
        var beerInPourName = "Unknown Beer"
        
        if let keg = self.kegs[pour.kegId] {
            if let beer = self.beers[keg.beerId] {
                beerInPourName = String(beer.nameDeprecated)
            }
        }
        
        cell.drinkerLabel.text = "\(drinkerName) - \(beerInPourName)"
        
        cell.amountLabel.text = String(pour.amount) + " L"
        
        //TODO: Convert timestamp into time
        cell.timeLabel.text = pour.getLastUpdateString()
    
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.handleReassignAction(indexPath: indexPath)
    }
 
    func tableView(_ tableView: UITableView,
                       trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        //
        let action = UIContextualAction(style: .normal,
                                        title: "Delete") { [weak self] (action, view, completionHandler) in
                                            self?.handleDeleteAction(indexPath: indexPath)
                                            completionHandler(true)
        }
        action.backgroundColor = .systemRed
        
        return UISwipeActionsConfiguration(actions: [action])

    }
}


// Table View Cell Action Handlers
extension ManagePoursViewController {
    
    //SECTION: TableViewCell swipe action handler
    private func handleDeleteAction(indexPath: IndexPath) {
        print("Row is: \(indexPath.row), pour info is: \(pours[indexPath.row])")
        
        // TODO: Fix removal animation
        poursRef.child(pours[indexPath.row].key).removeValue()
    }
    
    private func handleReassignAction(indexPath: IndexPath) {
//        print(pours[indexPath.row])
        
        self.selectedPour = self.pours[indexPath.row]
        self.selectedDrinker = self.drinkers[pours[indexPath.row].drinkerId]
        performSegue(withIdentifier: "ChangeDrinkerSegue", sender: self)
    }
    
    private func reassignPour(pour: Pour, newDrinker: Drinker) {
        print("reassignPour called")
    }
}

// Data helper functions
extension ManagePoursViewController {
    func setupData() {
        getDrinkers()
        getKegsAndBeers()
    }
    
    func getDrinkers() {
        drinkersRef.getData { (error, snapshot) in
            //TODO: Add error check
            var newItems = [String: Drinker]()
            
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let drinker = Drinker(snapshot: snapshot) {
                    newItems[drinker.key] = drinker
                }
            }
            
            self.drinkers = newItems
            
            self.refreshPoursData()
        }
    }
    
    func getKegsAndBeers() {
        kegsRef.getData { (error, snapshot) in
            //TODO: Add error check
            var newItems = [String: Keg]()
            
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let keg = Keg(snapshot: snapshot) {
                    newItems[keg.key] = keg
                }
            }
            
            self.kegs = newItems
        }
        
        beersRef.getData { (error, snapshot) in
            //TODO: Add error check
            var newItems = [String: Beer]()
            
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let beer = Beer(snapshot: snapshot) {
                    newItems[beer.key] = beer
                }
            }
            
            self.beers = newItems
        }
    }

    
    func refreshPoursData() {
//        poursRef.queryLimited(toLast: 20).observe(.value, with: { snapshot in
        poursRef.observe(.value, with: { snapshot in
            var newItems: [Pour] = []

            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let pour = Pour(snapshot: snapshot) {
                    newItems.append(pour)
                }
            }
            
            // Sort by newest -> latest
            self.pours = newItems.sorted(by: { $0.lastUpdate > $1.lastUpdate} )
            self.poursTableView.reloadData()
            
        })
    }
}
