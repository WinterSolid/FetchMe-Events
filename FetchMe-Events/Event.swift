// platform.seatgeek.com
//  Event.swift
//  FetchMe-Events
//
//  Created by Zakee T on 8/31/21.
//

import Foundation

// SeatGeek Coding/Decoding
struct Event: Codable {
    // All are Constants per endpoints
    public let title: String  // Event Title
    public let url: String // URL of Event
    public let stats: Int
    
    public let dateTime_local: String // Date times
    public let dateTime_utc: String
    public let date_tbd: Bool
    public let time_tbd: Bool
    
    public let performers: [Performer]
    public let venue: String
    public let short_title: String
    
    public let score: Float
    public let type: String
    public let id:  Int
    

    func formatDateTime() -> String {
        let dateFormatting = DateFormatter()
            dateFormatting.dateFormat = "yyyy-MM-dd'T'HH:mm:ss" //format per api doc
        let date = dateFormatting.date(from: dateTime_local)
        var dateTimeString: String!
        
    // Date/Time presentation logic
        if date_tbd && time_tbd {
            dateFormatting.dateFormat = "EEEE, MMMM d, yyyy"
            dateTimeString = "\(dateFormatting.string(from: date!))"
        }else if date_tbd && !time_tbd {
            dateFormatting.dateFormat = "EEEE, MMMM d, yyyy\nh:mm a"
            dateTimeString = dateFormatting.string(from: date!)
        } else if time_tbd {
            dateFormatting.dateFormat = "EEEE, MMMM d, yyyy"
            dateTimeString = dateFormatting.string(from: date!)
            dateTimeString.append("\nTime: TBD")
        } else {
            dateFormatting.dateFormat = "EEEE, MMMM d, yyyy\nh:mm a"
            dateTimeString = dateFormatting.string(from: date!)
        }
    }
    struct Events: Codable{
        var events: [Event]
    }
    
    func locationFormat() -> String{
        
        let city = ( venue.city != nil ? venue.city! : ""  )
        let state = ( venue.city != nil ? venue.city! : ""  )
        
        if (city != "" && state != "" ) {
            return "\(city),\(state)"
        } else if (city == "" && state != "" ) {
            return "\(state)"
        } else if (city != "" && state == "" ) {
            return "\(city)"
        }else {
            return "To Be Determined"
        }
    }
    
    
    
}
