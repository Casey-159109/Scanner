//
//  DataScannerView.swift
//  Scanner
//
//  Created by Casey on 11/07/22.
//

import Foundation
import SwiftUI
import VisionKit


struct DataScannerView : UIViewControllerRepresentable
{
    @Binding var recognizedItems: [RecognizedItem]
    let recognizedDataType: DataScannerViewController.RecognizedDataType
    let scanMultiple: Bool
    
    func makeUIViewController(context: Context) -> DataScannerViewController
    {
        let vc = DataScannerViewController(recognizedDataTypes: [recognizedDataType], qualityLevel: .balanced, recognizesMultipleItems: scanMultiple, isGuidanceEnabled: true, isHighlightingEnabled: true)
        return vc
    }
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        uiViewController.delegate = context.coordinator
        try? uiViewController.startScanning()
    }
    
    func makeCoordinator() -> Coordinator
    {
        Coordinator(recognizedItems: $recognizedItems)
    }
    
    static func dismantleUIViewController(_ uiViewController: DataScannerViewController, coordinator: Coordinator) {
        uiViewController.stopScanning()
    }
    
    class Coordinator: NSObject, DataScannerViewControllerDelegate
    {
        @Binding var recognizedItems: [RecognizedItem]
        
        init(recognizedItems: Binding<[RecognizedItem]>) {
            self._recognizedItems = recognizedItems
        }
        
        func dataScannerDidZoom(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            print("Tap")
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            print("ALL add")
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didRemove removedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            self.recognizedItems = recognizedItems.filter{ item in
                !removedItems.contains(where: {$0.id == item.id})
            }
            print("deleted")
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, becameUnavailableWithError error: DataScannerViewController.ScanningUnavailable) {
            print("unavailable")
        }
    }
}
