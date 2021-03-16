//
//  Pour.swift
//  OtterKeg
//
//  Created by Hanwen Xu on 2/28/21.
//

import Foundation

import Firebase

struct Pour {
  
    let ref: DatabaseReference?
    let key: String

    let amount: Double
    let drinkerId: String
    let isCurrent: Bool
    let kegId: String
    let lastUpdate: Date
    let start: String
        
    init(key: String, amount: Double, drinkerId: String, isCurrent: Bool, kegId: String, lastUpdate: Date, start: String) {
        self.ref = nil
        
        self.key = key
        self.amount =  amount
        self.drinkerId = drinkerId
        self.isCurrent = isCurrent
        self.kegId = kegId
        self.lastUpdate = lastUpdate
        self.start = start
    }
    
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let amount = value["amount"] as? Double,
            let drinkerId = value["drinkerId"] as? String,
            let isCurrent = value["isCurrent"] as? Bool,
            let kegId = value["kegId"] as? String,
            let lastUpdateDateString = value["lastUpdate"] as? String,
            let start = value["start"] as? String else {
            return nil
        }
        
        self.ref = snapshot.ref
        self.key = snapshot.key
        
        self.amount =  amount
        self.drinkerId = drinkerId
        self.isCurrent = isCurrent
        self.kegId = kegId
        self.lastUpdate = Pour.convertDateFormatter(date: lastUpdateDateString)
        self.start = start

    }
  
    func toAnyObject() -> Any {
        return [
            "amount": amount,
            "drinkerId": drinkerId,
            "isCurrent": isCurrent,
            "kegId": kegId,
            "lastUpdate": lastUpdate,
            "start": start
        ]
    }
    
    func getLastUpdateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy hh:mm a"
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?

        return dateFormatter.string(from: self.lastUpdate)
    }
    
    // https://www.datetimeformatter.com/how-to-format-date-time-in-swift/#swift4
    static func convertDateFormatter(date: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        dateFormatter.locale = Locale(identifier: "your_loc_id")
        
        guard let convertedDate = dateFormatter.date(from: date) else {
                assert(false, "no date from string")
            return Date()
        }
        
        return convertedDate
    }
}
