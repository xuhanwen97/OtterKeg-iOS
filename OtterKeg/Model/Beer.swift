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
    let untappedBid: Double
    
    internal init(key: String, nameDeprecated: String, untappedBid: Double) {
        self.ref = nil
        
        self.key = key
        self.nameDeprecated = nameDeprecated
        self.untappedBid = untappedBid
    }
    
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let nameDeprecated = value["nameDeprecated"] as? String,
            let untappedBid = value["untappedBid"] as? Double else {
            return nil
        }
        
        self.ref = snapshot.ref
        self.key = snapshot.key

        self.nameDeprecated = nameDeprecated
        self.untappedBid = untappedBid
    }

    func toAnyObject() -> Any {
        return [
            "nameDeprecated": nameDeprecated,
            "untappedBid": untappedBid,
        ]
    }
}
