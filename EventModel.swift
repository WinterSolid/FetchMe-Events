//
//  EventModel.swift
//  FetchMe-Events
//
//  Created by Zakee T on 8/31/21.
//

import Foundation

// SeatGeek Coding/Decoding
struct EventModel: Codable {
    // All are Constants per endpoints
    public let title: String  // Event Title
    public let url: String // URL of Event
    
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
            dateFormatting.dateFormat = "dd-MM-yyyy"
        let date = dateFormatting.date(from: datetime_local)
        var dateTimeString: String!
        
    // Date/Time presentation logic
        if date_tbd && time_tbd {
            dateFormatting.dateFormat = "
        }
    }
    
    
    
    
}
