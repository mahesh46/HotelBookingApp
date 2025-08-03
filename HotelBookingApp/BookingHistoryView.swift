//
//  BookingHistoryView.swift
//  HotelBookingApp
//
//  Created by mahesh lad on 18/07/2025.
//

import SwiftUI
import CoreData

struct BookingHistoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \BookingEntity.checkInDate, ascending: true)],
        animation: .default)
    private var bookings: FetchedResults<BookingEntity>
    
    var body: some View {
        Group {
            if bookings.isEmpty {
                VStack {
                    Image(systemName: "suitcase.cart")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("No Bookings Yet")
                        .font(.headline)
                        .padding(.top)
                }
            } else {
                List {
                    ForEach(bookings) { bookingEntity in
                        if let booking = booking(from: bookingEntity) {
                            BookingHistoryRow(booking: booking)
                        }
                    }
                    .onDelete(perform: deleteBookings)
                }
            }
        }
        .navigationTitle("Booking History")
        .toolbar {
            if !bookings.isEmpty {
                EditButton()
            }
        }
    }
    
    private func deleteBookings(offsets: IndexSet) {
        withAnimation {
            offsets.map { bookings[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func booking(from entity: BookingEntity) -> Booking? {
        guard let hotelData = entity.hotelData,
              let hotel = try? JSONDecoder().decode(Hotel.self, from: hotelData) else {
            return nil
        }
        return Booking(id: entity.id ?? UUID(),
                       hotel: hotel,
                       checkInDate: entity.checkInDate ?? Date(),
                       checkOutDate: entity.checkOutDate ?? Date())
    }
}

struct BookingHistoryRow: View {
    let booking: Booking
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(booking.hotel.name)
                .font(.headline)
            Text(booking.hotel.location)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Divider()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Check-In")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(booking.checkInDate, style: .date)
                        .font(.subheadline)
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("Check-Out")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(booking.checkOutDate, style: .date)
                        .font(.subheadline)
                }
            }
            
            Divider()
            
            HStack {
                Text("Total Price:")
                    .font(.headline)
                Spacer()
                Text("£\(booking.totalPrice, specifier: "%.2f")")
                    .font(.headline)
                    .fontWeight(.bold)
            }
        }
        .padding(.vertical)
    }
}

struct BookingHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BookingHistoryView()
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
        }
    }
}
