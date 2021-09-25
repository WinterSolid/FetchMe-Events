//
//  Recommendations.swift
//  FetchMe-Events
//
//  Created by Zakee Tanksley on 9/1/21.
// Recommendations

import Foundation
struct Recommendation: Codable {

    public let event: Event
    public let score: Int
    
    private enum CodingKeys: String, CodingKey {
        case event
        case score
    }
}

struct Recommendations: Codable {
    let recommendations: [Recommendation]
}
