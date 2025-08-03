//
//  HotelDetailView.swift
//  HotelBookingApp
//
//  Created by mahesh lad on 17/07/2025.
//

import SwiftUI
import CoreData

// Data structure for the sheet
struct BookingConfirmationDetails: Identifiable {
    let id = UUID()
    let hotel: Hotel
    let checkInDate: Date
    let checkOutDate: Date
    let numberOfNights: Int
    let totalPrice: Double
}

// The confirmation sheet now manages its own alerts.
struct BookingConfirmationView: View {
    @Environment(\.dismiss) var dismiss
    
    let details: BookingConfirmationDetails
    // The action now returns an optional error message.
    let confirmAction: () -> String?
    
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Confirm Your Booking")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text(details.hotel.name).font(.title2).fontWeight(.semibold)
                    Text(details.hotel.location).font(.title3).foregroundColor(.secondary)
                    
                    Divider()
                    
                    VStack(spacing: 12) {
                        HStack {
                            Text("Check-In:")
                            Spacer()
                            Text(details.checkInDate, style: .date)
                        }
                        HStack {
                            Text("Check-Out:")
                            Spacer()
                            Text(details.checkOutDate, style: .date)
                        }
                        HStack {
                            Text("Number of Nights:")
                            Spacer()
                            Text("\(details.numberOfNights)")
                        }
                    }
                    .font(.headline)

                    Divider()

                    HStack {
                        Text("Total Price")
                        Spacer()
                        Text("£\(details.totalPrice, specifier: "%.2f")")
                    }
                    .font(.title2)
                    .fontWeight(.bold)
                }
                
                Spacer()
                
                Button("Pay & Confirm") {
                    // If the action returns an error, show the alert.
                    if let error = confirmAction() {
                        self.errorMessage = error
                        self.showErrorAlert = true
                    } else {
                        // Otherwise, dismiss the sheet.
                        dismiss()
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .frame(maxWidth: .infinity)
            }
            .padding()
            .navigationBarItems(leading: Button("Cancel") {
                dismiss()
            })
            .navigationBarTitleDisplayMode(.inline)
            // Attach the alert to this view.
            .alert(isPresented: $showErrorAlert) {
                Alert(title: Text("Booking Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}


struct HotelDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let hotel: Hotel
    
    @State private var checkInDate = Date()
    @State private var checkOutDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
    
    @State private var bookingConfirmationDetails: BookingConfirmationDetails?
    @State private var bookingConfirmed = false
    
    private var numberOfNights: Int {
        let startOfCheckIn = Calendar.current.startOfDay(for: checkInDate)
        let startOfCheckOut = Calendar.current.startOfDay(for: checkOutDate)
        return Calendar.current.dateComponents([.day], from: startOfCheckIn, to: startOfCheckOut).day ?? 0
    }
    
    private var totalPrice: Double {
        Double(numberOfNights) * hotel.pricePerNight
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Image(hotel.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 250)
                    .clipped()
                
                VStack(alignment: .leading, spacing: 16) {
                    Text(hotel.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(hotel.location)
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text("£\(hotel.pricePerNight, specifier: "%.2f")/night")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("\(hotel.rating, specifier: "%.1f")")
                                .font(.title3)
                        }
                    }
                    
                    Divider()
                    
                    VStack(spacing: 16) {
                        DatePicker("Check-In", selection: $checkInDate, in: Date()..., displayedComponents: .date)
                        DatePicker("Check-Out", selection: $checkOutDate, in: checkInDate..., displayedComponents: .date)
                    }
                    .font(.headline)
                    
                    if bookingConfirmed {
                        Text("✅ Booking Confirmed!")
                            .foregroundColor(.green)
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        Button("Continue") {
                            bookingConfirmationDetails = BookingConfirmationDetails(
                                hotel: hotel,
                                checkInDate: checkInDate,
                                checkOutDate: checkOutDate,
                                numberOfNights: numberOfNights,
                                totalPrice: totalPrice
                            )
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding()
            }
        }
        .navigationTitle(hotel.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $bookingConfirmationDetails) { details in
            BookingConfirmationView(
                details: details,
                confirmAction: confirmBooking
            )
        }
    }
    
    private func findConflictingBooking() -> Booking? {
        let request: NSFetchRequest<BookingEntity> = BookingEntity.fetchRequest()
        
        let startOfNewBooking = Calendar.current.startOfDay(for: checkInDate)
        let endOfNewBooking = Calendar.current.startOfDay(for: checkOutDate)
        
        // This new, efficient predicate filters by hotel name AND date overlap in the database.
        let namePredicate = NSPredicate(format: "hotelName == %@", hotel.name)
        let overlapPredicate = NSPredicate(format: "checkInDate < %@ AND checkOutDate > %@", endOfNewBooking as NSDate, startOfNewBooking as NSDate)
        
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [namePredicate, overlapPredicate])
        
        do {
            // If a conflicting entity is found, we decode it to return for the error message.
            if let conflictingEntity = try viewContext.fetch(request).first {
                guard let hotelData = conflictingEntity.hotelData,
                      let bookedHotel = try? JSONDecoder().decode(Hotel.self, from: hotelData) else {
                    return nil
                }
                return Booking(id: conflictingEntity.id ?? UUID(),
                               hotel: bookedHotel,
                               checkInDate: conflictingEntity.checkInDate ?? Date(),
                               checkOutDate: conflictingEntity.checkOutDate ?? Date())
            }
            return nil // No conflict found
            
        } catch {
            print("Error fetching bookings: \(error)")
            return nil
        }
    }

    // This function now returns an error message string on failure, or nil on success.
    private func confirmBooking() -> String? {
        guard numberOfNights > 0 else {
            return "Check-out date must be after check-in date."
        }
        
        if let conflictingBooking = findConflictingBooking() {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return "This hotel is already booked from \(formatter.string(from: conflictingBooking.checkInDate)) to \(formatter.string(from: conflictingBooking.checkOutDate)). Please select different dates."
        }
        
        let newBooking = BookingEntity(context: viewContext)
        newBooking.id = UUID()
        newBooking.checkInDate = checkInDate
        newBooking.checkOutDate = checkOutDate
        newBooking.hotelName = hotel.name // Save the hotel name
        
        do {
            newBooking.hotelData = try JSONEncoder().encode(hotel)
            try viewContext.save()
            bookingConfirmed = true
            return nil // Success
        } catch {
            return "Failed to save booking: \(error.localizedDescription)"
        }
    }
}
//#Preview {
//    HotelDetailView(hotel: .preview)
//}
