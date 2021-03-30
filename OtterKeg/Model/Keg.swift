//
//  Keg.swift
//  OtterKeg
//
//  Created by Hanwen Xu on 3/28/21.
//

import Foundation
import Firebase

struct Keg {
    let ref: DatabaseReference?
    let key: String

    let beerId: String
    let isActive: Bool
    let position: String
    let sizeInPints: Double
    
    internal init(key: String, beerId: String, isActive: Bool, position: String, sizeInPints: Double) {
        self.ref = nil
        
        self.key = key
        self.beerId = beerId
        self.isActive = isActive
        self.position = position
        self.sizeInPints = sizeInPints
    }
    
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let beerId = value["beerId"] as? String,
            let isActive = value["isActive"] as? Bool,
            let position = value["position"] as? String,
            let sizeInPints = value["sizeInPints"] as? Double else {
            return nil
        }
        
        self.ref = snapshot.ref
        self.key = snapshot.key

        self.beerId = beerId
        self.isActive = isActive
        self.position = position
        self.sizeInPints = sizeInPints
    }

    func toAnyObject() -> Any {
        return [
            "beerId": beerId,
            "isActive": isActive,
            "position": position,
            "sizeInPints": sizeInPints
        ]
    }
}
