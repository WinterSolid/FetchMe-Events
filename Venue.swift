//
//  Venue.swift
//  FetchMe-Events
//
//  Created by Zakee T on 8/31/21.
//  Venue: City, State

import Foundation

struct Venue: Codable {
    
    public let city: String?
    public let state: String?
    
    private enum CodingKeys: String, CodingKey {
        case city
        case state
    }
    
}
