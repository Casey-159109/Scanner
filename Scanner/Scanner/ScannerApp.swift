//
//  ScannerApp.swift
//  Scanner
//
//  Created by Casey on 10/07/22.
//

import SwiftUI

@main
struct ScannerApp: App {
    
    @StateObject private var vm = AppViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(vm)
                .task {
                    await vm.requestDataScannerAccessStatus()
                }
        }
    }
}


