import SwiftUI

enum ScannerError: Error, Identifiable {
    case cameraPermissionDenied
    case cameraSetupFailed
    case imageProcessingFailed
    case invalidDeviceInput
    
    var id: String { message }
    
    var message: String {
        switch self {
        case .cameraPermissionDenied:
            return "Camera access is required. Please enable it in Settings."
        case .cameraSetupFailed:
            return "Failed to setup camera. Please try again."
        case .imageProcessingFailed:
            return "Failed to process image. Please try again."
        case .invalidDeviceInput:
                    return "Failed to setup camera input. Please try again."
        }
    }
}

@MainActor
class ScannerViewModel: ObservableObject {
    @Published var isShowingScanner = false
    @Published var scannedCode: String?
    @Published var error: ScannerError?
    
    func startScanning() {
        isShowingScanner = true
        error = nil
        scannedCode = nil
    }
    
    func stopScanning() {
        isShowingScanner = false
    }
}
