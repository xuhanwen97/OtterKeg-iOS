//
//  Beer.swift
//  OtterKeg
//
//  Created by Hanwen Xu on 3/28/21.
//

import Foundation
import Firebase

struct Beer {
    let ref: DatabaseReference?
    let key: String

    //nameDeprecated is not actually used to dispay info on OtterKeg terminals
    let nameDeprecated: String
    let untappdBid: Double
    
    internal init(key: String, nameDeprecated: String, untappdBid: Double) {
        self.ref = nil
        
        self.key = key
        self.nameDeprecated = nameDeprecated
        self.untappdBid = untappdBid
    }
    
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let nameDeprecated = value[BeerConstants.beerDBKeyNameDeprecated] as? String,
            let untappdBid = value[BeerConstants.beerDbKeyUntappdBid] as? Double else {
            return nil
        }
        
        self.ref = snapshot.ref
        self.key = snapshot.key

        self.nameDeprecated = nameDeprecated
        self.untappdBid = untappdBid
    }

    func toAnyObject() -> Any {
        return [
            BeerConstants.beerDBKeyNameDeprecated: nameDeprecated,
            BeerConstants.beerDbKeyUntappdBid: untappdBid,
        ]
    }
}
