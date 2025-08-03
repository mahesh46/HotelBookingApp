//
//  Hotel.swift
//  HotelBookingApp
//
//  Created by mahesh lad on 17/07/2025.
//

import Foundation

struct Hotel: Identifiable, Hashable, Codable {
    let id: UUID
    let name: String
    let location: String
    let imageName: String
    let pricePerNight: Double
    let rating: Double
}

