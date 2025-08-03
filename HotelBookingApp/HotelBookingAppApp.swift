//
//  HotelBookingAppApp.swift
//  HotelBookingApp
//
//  Created by mahesh lad on 17/07/2025.
//

import SwiftUI

@main
struct HotelBookingApp: App {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                HotelListView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            } else {
                LoginView()
            }
        }
    }
}
