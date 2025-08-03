//
//  Booking.swift
//  HotelBookingApp
//
//  Created by mahesh lad on 18/07/2025.
//

import Foundation

struct Booking: Identifiable, Hashable {
    let id: UUID
    let hotel: Hotel
    let checkInDate: Date
    let checkOutDate: Date
    
    var durationInNights: Int {
        let startOfCheckIn = Calendar.current.startOfDay(for: checkInDate)
        let startOfCheckOut = Calendar.current.startOfDay(for: checkOutDate)
        return Calendar.current.dateComponents([.day], from: startOfCheckIn, to: startOfCheckOut).day ?? 0
    }
    
    var totalPrice: Double {
        Double(durationInNights) * hotel.pricePerNight
    }
}
