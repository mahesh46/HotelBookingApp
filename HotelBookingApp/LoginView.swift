//
//  LoginView.swift
//  HotelBookingApp
//
//  Created by mahesh lad on 17/07/2025.
//
import SwiftUI

struct LoginView: View {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @State private var username = ""
    @State private var password = ""

    var body: some View {
        VStack(spacing: 20) {
            
            Image(systemName: "building.2.crop.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.accentColor)

            Text("Welcome")
                .font(.largeTitle)
                .fontWeight(.bold)

            VStack {
                TextField("Username", text: $username)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.username)
                    .autocapitalization(.none)
                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.password)
            }

            Button("Login") {
                // Simple validation for demonstration
                if username == "guest" && password == "password" {
                    isLoggedIn = true
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
    }
}
