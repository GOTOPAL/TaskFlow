//
//  TaskFlowApp.swift
//  TaskFlow
//
//  Created by Göktuğ Oğuzhan TOPAL on 25.07.2025.
//

import SwiftUI

@main
struct TaskFlowApp: App {
    @StateObject var session = SessionManager()
    var body: some Scene {
        WindowGroup {
            if session.isAuthenticated {
                           HomeView()
                               .environmentObject(session)
                       } else {
                           LoginView()
                               .environmentObject(session)
                       }
        }
    }
}
