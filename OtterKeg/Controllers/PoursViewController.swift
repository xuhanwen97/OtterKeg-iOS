//
//  ViewController.swift
//  OtterKeg
//
//  Created by Hanwen Xu on 2/26/21.
//

import UIKit
import Firebase

class PoursViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var poursTableView: UITableView!
    
    var pours: [Pour] = []
    let poursRef = Database.database().reference(withPath: "pours")
    
    var drinkers = [String: Drinker]()
    let drinkersRef = Database.database().reference(withPath: "drinkers")
    
    let otterKegBackground = UIColor(red: 0.13, green: 0.17, blue: 0.20, alpha: 1.00)
    
    lazy var slideInTransitioningDelegate = SlideInPresentationManager()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            navBarAppearance.backgroundColor = otterKegBackground
            
            self.navigationController?.navigationBar.standardAppearance = navBarAppearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance

            navigationController?.navigationBar.prefersLargeTitles = true
            self.title = "OtterKeg Pours"
        }
        
        self.poursTableView.showsVerticalScrollIndicator = false
        self.poursTableView.separatorColor = .lightGray
        self.poursTableView.separatorInset = .zero
        
        // Do any additional setup after loading the view.
        
        getDrinkers()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? ChangeDrinkerController {
            if segue.identifier == "ChangeDrinkerSegue" {
                    
                //TODO: Setup the delegate structure for the other controller
//                controller.delegate = self
//                controller.transitioningDelegate = slideInTransitioningDelegate
                slideInTransitioningDelegate.direction = .bottom

                controller.transitioningDelegate = slideInTransitioningDelegate
                controller.modalPresentationStyle = .custom
            }
        }
    }
    
    
    // Table View Controllers
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pours.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PourCell", for: indexPath) as! PourTableViewCell
        let pour = pours[indexPath.row]
        
        cell.drinkerLabel.text = self.drinkers[pour.drinkerId]?.name
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
    
    
    //SECTION: TableViewCell swipe action handler
    private func handleDeleteAction(indexPath: IndexPath) {
        print("Row is: \(indexPath.row), pour info is: \(pours[indexPath.row])")
        
        // TODO: Fix removal animation
//        pours.remove(at: indexPath.row)
//        self.poursTableView.deleteRows(at: [indexPath], with: .automatic)

        poursRef.child(pours[indexPath.row].key).removeValue()
    }
    
    private func handleReassignAction(indexPath: IndexPath) {
        print(pours[indexPath.row])
        
//        let presentationController = SlideInPresentationController(
//            presentedViewController: presented,
//            presenting: self,
//            direction: .bottom
//        )
//        return presentationController
        
    }
    
    private func reassignPour(pour: Pour, newDrinker: Drinker) {
        
    }
    
}

