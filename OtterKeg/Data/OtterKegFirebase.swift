//
//  OtterKegFirebase.swift
//  OtterKeg
//
//  Created by Hanwen Xu on 3/26/22.
//

import Foundation
import Firebase

class OtterKegFirebase {
    static let sharedFirebase = OtterKegFirebase()
    
    var pours: [Pour] = []
    let poursRef = Database.database().reference(withPath: "pours")
    
    var drinkers = [String: Drinker]()
    let drinkersRef = Database.database().reference(withPath: "drinkers")
    
    var kegs = [String: Keg]()
    let kegsRef = Database.database().reference(withPath: "kegs")
    
    var beers = [String: Beer]()
    let beersRef = Database.database().reference(withPath: "beers")
    
    func getDrinkers(onError: ((Error?) -> Void)?,  onCompletion: @escaping ([String : Drinker]) -> Void) {
                
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
            onCompletion(self.drinkers)
        }
    }
    
    func getKegs(onError: ((Error?) -> Void)?,  onCompletion: @escaping ([String : Keg]) -> Void) {
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
            onCompletion(self.kegs)
        }
    }
    
    func getBeers(onError: ((Error?) -> Void)?,  onCompletion: @escaping ([String : Beer]) -> Void) {
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
            onCompletion(self.beers)
        }
    }

    
    func getPours(onError: ((Error?) -> Void)?,  onCompletion: @escaping ([Pour]) -> Void) {
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
            onCompletion(self.pours)
        })
    }
}
