//
//  HotelCardView.swift
//  HotelBookingApp
//
//  Created by mahesh lad on 17/07/2025.
//

import SwiftUI

struct HotelCardView: View {
    let hotel: Hotel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Image(hotel.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 180)
                .clipped()

            VStack(alignment: .leading, spacing: 8) {
                Text(hotel.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(hotel.location)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                HStack {
                    Text("£\(hotel.pricePerNight, specifier: "%.2f")/night")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("\(hotel.rating, specifier: "%.1f")")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

