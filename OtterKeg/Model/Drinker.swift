//
//  Drinker.swift
//  OtterKeg
//
//  Created by Hanwen Xu on 3/3/21.
//

import Foundation
import Firebase

struct Drinker {
    
    let ref: DatabaseReference?
    let key: String

    let isActive: Bool
    let name: String
    
    internal init(key: String, isActive: Bool, name: String) {
        self.ref = nil
        
        self.key = key
        self.isActive = isActive
        self.name = name
    }
    
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let isActive = value["isActive"] as? Bool,
            let name = value["name"] as? String else {
            return nil
        }
        
        self.ref = snapshot.ref
        self.key = snapshot.key

        self.isActive = isActive
        self.name = name
    }

    func toAnyObject() -> Any {
        return [
            "isActive": isActive,
            "name": name
        ]
    }

}

extension Drinker: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(key)
        hasher.combine(name)
    }
}
