//
//  iOSApp3App.swift
//  iOSApp3
//
//  Application entry point.
//
//  Created by stephanie otteson on 2026-06-18.
//

import SwiftUI

/// App bootstrap and root scene configuration.
@main
struct iOSApp3App: App {
    var body: some Scene {
        WindowGroup {
            // Root screen for map-based museum navigation.
            MuseumMapView()
        }
    }
}
