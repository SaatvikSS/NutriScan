import SwiftUI
import AVFoundation
import Vision

struct CameraView: UIViewControllerRepresentable {
    @ObservedObject var viewModel: ScannerViewModel
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        
        // Capture session setup
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        
        // Camera authorization
        func setupCamera() {
            guard let captureDevice = AVCaptureDevice.default(
                .builtInWideAngleCamera,
                for: .video,
                position: .back
            ) else {
                viewModel.error = .invalidDeviceInput
                return
            }
            
            do {
                let input = try AVCaptureDeviceInput(device: captureDevice)
                
                if captureSession.canAddInput(input) {
                    captureSession.addInput(input)
                }
                
                let videoOutput = AVCaptureVideoDataOutput()
                videoOutput.setSampleBufferDelegate(
                    context.coordinator,
                    queue: DispatchQueue(label: "videoQueue")
                )
                
                if captureSession.canAddOutput(videoOutput) {
                    captureSession.addOutput(videoOutput)
                }
                
                let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer.frame = viewController.view.bounds
                previewLayer.videoGravity = .resizeAspectFill
                viewController.view.layer.addSublayer(previewLayer)
                
                DispatchQueue.global(qos: .userInitiated).async {
                    captureSession.startRunning()
                }
            } catch {
                viewModel.error = .invalidDeviceInput
            }
        }
        
        // Handle permissions
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        setupCamera()
                    }
                } else {
                    viewModel.error = .cameraPermissionDenied
                }
            }
        case .denied, .restricted:
            viewModel.error = .cameraPermissionDenied
        @unknown default:
            viewModel.error = .cameraSetupFailed
        }
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            
            let ciImage = CIImage(cvPixelBuffer: imageBuffer)
            let context = CIContext()
            guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }
            
            let image = UIImage(cgImage: cgImage)
            processImage(image)
        }
        
        private func processImage(_ image: UIImage) {
            guard let cgImage = image.cgImage else {
                Task { @MainActor in
                    parent.viewModel.error = .imageProcessingFailed
                }
                return
            }
            
            let handler = VNImageRequestHandler(cgImage: cgImage)
            let request = VNDetectBarcodesRequest { request, error in
                if let error = error {
                    Task { @MainActor in
                        self.parent.viewModel.error = .imageProcessingFailed
                    }
                    return
                }
                
                guard let results = request.results as? [VNBarcodeObservation],
                      let barcode = results.first,
                      let payload = barcode.payloadStringValue else {
                    return
                }
                
                Task { @MainActor in
                    self.parent.viewModel.scannedCode = payload
                    self.parent.viewModel.stopScanning()
                }
            }
            
            do {
                try handler.perform([request])
            } catch {
                Task { @MainActor in
                    parent.viewModel.error = .imageProcessingFailed
                }
            }
        }
    }
}
