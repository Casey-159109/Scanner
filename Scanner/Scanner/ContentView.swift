//
//  ContentView.swift
//  Scanner
//
//  Created by Casey on 10/07/22.
//

import SwiftUI
import VisionKit

struct ContentView: View {

    @EnvironmentObject var vm : AppViewModel
    
    private let textContentTypes: [(title: String, textContentType: DataScannerViewController.TextContentType?)] = [
        ("All", .none),
        ("URL", .URL),
        ("Phone", .telephoneNumber),
        ("Email", .emailAddress),
        ("Address", .fullStreetAddress)
    ]
    
    var body: some View
    {
        switch vm.dataScannerAccessStatusType
        {
            case .scannerAvailable:
                mainView
            case .cameraNotAvailable:
                Text("Your device doesn't have a camera")
            case .scannerNotAvailable:
                Text("Your device doesn't have support for scanning barcode with this app")
            case .cameraAccessNotGranted:
                Text("Please provide access to the camera in settings")
            case .notDetermined:
                Text("Requesting camera access")
        }
    }
    
    private var mainView: some View
    {
        DataScannerView(recognizedItems: $vm.recognizedItems, recognizedDataType: vm.recognizedDataType, scanMultiple: vm.recognizesMultipleItem)
        .background {Color.gray.opacity(0.3)}
        .ignoresSafeArea()
        .id(vm.dataScannerViewID)
        .sheet(isPresented: .constant(true)){
            bottomContainerView
            .background(.ultraThinMaterial)
            .presentationDetents([.medium, .fraction(0.25)])
            .presentationDragIndicator(.visible)
            .interactiveDismissDisabled()
            .onAppear(){
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let controller = windowScene.windows.first?.rootViewController?.presentedViewController else{
                    return
                }
                controller.view.backgroundColor = .clear
            }
        }
        .onChange(of: vm.scanType) {_ in vm.recognizedItems = []}
        .onChange(of: vm.scanTextType) {_ in vm.recognizedItems = []}
        .onChange(of: vm.recognizesMultipleItem) {_ in vm.recognizedItems = []}
    }
    
    private var headerView: some View
    {
        VStack{
            HStack{
                Picker("Scan Type", selection: $vm.scanType) {
                    Text("Barcode").tag(ScanType.barcode)
                    Text("Text").tag(ScanType.text)
                }.pickerStyle(.segmented)
                Toggle("Scan Multiple", isOn: $vm.recognizesMultipleItem)
            }.padding(.top)
            
            if vm.scanType ==  .text
            {
                Picker("Text Content Type", selection: $vm.scanType){
                    ForEach(textContentTypes, id: \.self.textContentType){ option in
                        Text(option.title).tag(option.textContentType)
                    }
                }.pickerStyle(.segmented)
            }
            Text(vm.headerText).padding(.top)
        }.padding(.horizontal)
    }

    private var bottomContainerView: some View
    {
        VStack{
            headerView
            ScrollView{
                LazyVStack(alignment: .leading, spacing: 16){
                    ForEach(vm.recognizedItems){ item in
                        switch item
                        {
                        case .barcode(let barcode):
                            Text(barcode.payloadStringValue ?? "Unknown Barcode")
                        case .text(let text):
                            Text(text.transcript)
                        @unknown default:
                            Text("Unknown")
                        }
                    }
                }.padding()
            }
        }
    }
}
