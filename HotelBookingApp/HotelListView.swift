//
//  HotelListView.swift
//  HotelBookingApp
//
//  Created by mahesh lad on 17/07/2025.
//

import SwiftUI
import CoreData

struct HotelListView: View {
    
    let sampleHotels = [
        Hotel(id: UUID(), name: "The Grand", location: "London", imageName: "hotel1", pricePerNight: 180, rating: 4.5),
        Hotel(id: UUID(), name: "Cozy Stay", location: "Manchester", imageName: "hotel2", pricePerNight: 90, rating: 4.0)
    ]
    
    var body: some View {
        NavigationView {
            List(sampleHotels) { hotel in
                ZStack {
                    NavigationLink(destination: HotelDetailView(hotel: hotel)) {
                        EmptyView()
                    }
                    .opacity(0)
                    
                    HotelCardView(hotel: hotel)
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .navigationTitle("Book a Stay")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: BookingHistoryView()) {
                        Image(systemName: "clock.fill")
                    }
                }
            }
        }
    }
}

//#Preview {
//    HotelListView()
//}
struct HotelListView_Previews: PreviewProvider {
    static var previews: some View {
        HotelListView()
    }
}
