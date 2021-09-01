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
    
    public let datetime_local: String // Date times
    public let datetime_utc: String
    public let date_tbd: Bool
    public let time_tbd: Bool
    
    public let performers: [performer]
    public let venue: String
    public let short_title: String
    
    public let score: Float
    public let type: String
    public let id:  Int
    

    func formatDatTime() -> String {
        let dateFormatting = DateFormatter()
            dateFormatting.dateFormat = "yyyy-MM-dd'T'HH:mm:ss" //format per api doc
        let date = dateFormatting.date(from: datetime_local)
        var dateTimeString: String!
        
    // Date/Time presentation logic
        if date_tbd && time_tbd {
            dateFormatting.dateFormat = "
        }
    }
    
    
    
    
}
