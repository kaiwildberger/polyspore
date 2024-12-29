//
//  ContentView.swift
//  fallenlog
//
//  Created by Kai Wildberger on 12/27/24.
//

import SwiftUI
import CoreData
import AVFoundation // probably necessary here
import AVKit // playback (preview?)

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    var body: some View {
        NavigationView {
            VStack {
                CameraView()
            }
            .toolbar {
                ToolbarItem {
                    NavigationLink {
                        Text("export yuor data!!!")
                    } label: {
                        Button(action: notelistView) {
                            Label("Export", systemImage: "square.and.arrow.up")
                        }
                    }
                }
                ToolbarItem {
                    NavigationLink {
                        // settings page
                        Text("Settings")
                        // export mostly
                        // name on export (for labelling entries)
                    } label: {
                        Button(action: settingsView) {
                            Label("Options", systemImage: "gearshape")
                        }
                    }
                }
            }
        }
    }
    
    private func settingsView() {
        // what do
    }
    
    private func notelistView() {
        // what do
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

struct CameraView: View {
    @Environment(\.dismiss) var dismiss
    @State private var isShowingCamera = false
    @StateObject var camera = CameraModel()
    
    var body: some View {
        Button(action: {isShowingCamera.toggle()}, label: {
            Image(systemName: "camera.viewfinder")
            
        })
        .fullScreenCover(isPresented: $isShowingCamera, onDismiss: cameraDismissed, content: {
            ZStack {
                CameraPreview(camera: camera)
                //            Color.black
                    .ignoresSafeArea(.all, edges: .all)
                VStack {
                    if camera.isTaken {
                        HStack {
                            Button(action: {
                                isShowingCamera.toggle()
                            }, label: {
                                Image(systemName: "chevron.backward.2")
                                    .foregroundStyle(Color.black)
                                    .padding()
                                    .background(Color.white)
                                    .clipShape(Circle())
                            })
                            .padding(.leading,10)
                            if camera.couldNotRecord {
                                Text("Try again")
                                    .bold()
                                    .background(Color.white)
                                    .padding(.vertical,10)
                                    .padding(.horizontal,10)
                                    .clipShape(.rect)
                            }
                            Spacer()
                            Button(action: camera.retake, label: {
                                Image(systemName: "arrow.triangle.2.circlepath.camera")
                                    .foregroundStyle(Color.black)
                                    .padding()
                                    .background(Color.white)
                                    .clipShape(Circle())
                            })
                            .padding(.trailing,10)
                        }
                    }
                    Spacer()
                    HStack {
                        if camera.isTaken {
                            Button(action: {if !camera.isSaved{camera.savePic()}}, label: {
                                Text(camera.isSaved ? "Saved":"Save")
                                    .foregroundStyle(Color.black)
                                    .fontWeight(.semibold)
                                    .padding(.vertical,10)
                                    .padding(.horizontal,20)
                                    .background(Color.white)
                                    .clipShape(.capsule)
                            })
                            .padding(.leading)
                            .disabled(camera.couldNotRecord)
                        } else {
                            Button(action: camera.takepic, label: {
                                ZStack {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width:65, height:65)
                                    Circle()
                                        .stroke(Color.white,lineWidth: 2)
                                        .frame(width:75,height: 75)
                                }
                            })
                        }
                    }
                    .frame(height:75)
                }
            }
            .onAppear(perform: {
                camera.check()
                
            })
        })
    }
    public func cameraDismissed() {
        camera.session.stopRunning()
        camera.isTaken = false
    }
}

struct CameraPreview: UIViewRepresentable {
    @ObservedObject var camera: CameraModel
    
    func makeUIView(context: Context) -> UIView {
        let view = UIViewType(frame: UIScreen.main.bounds)
        DispatchQueue.main.async {
            camera.preview = AVCaptureVideoPreviewLayer(session: camera.session)
            camera.preview.frame = view.frame
            
            // some other properties ig
            camera.preview.videoGravity = .resizeAspectFill
            view.layer.addSublayer(camera.preview)
            
            camera.session.startRunning()
        }
        
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}

class CameraModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published var isTaken = false;
    @Published var session = AVCaptureSession()
    @Published var alert = false;
    @Published var output = AVCapturePhotoOutput()
    @Published var preview: AVCaptureVideoPreviewLayer!
    @Published var picData = Data(count: 0)
    @Published var isSaved = false
    @Published var couldNotRecord = false
    func check() {
        // camera permission
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // Yes Allow
            self.setup()
            return
        case .notDetermined: // not yet
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (status) in
                if status {
                    self.setup()
                }
            })
        case .restricted: // "isn't permitted"
            self.alert.toggle()
            return
        case .denied: // explicitly denied
            self.alert.toggle()
            return
        default:
            return
        }
    }
    
    func setup() {
        do {
            self.session.beginConfiguration()
            if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                do {
                    let input = try AVCaptureDeviceInput(device: device)
                    if self.session.canAddInput(input) {
                        self.session.addInput(input)
                    }
                    
                    if self.session.canAddOutput(self.output) {
                        self.session.addOutput(self.output)
                    }
                    
                    self.session.commitConfiguration()
                } catch {
                    print("error in setup")
                }
            } else {
                print("camera not avaialble")
            }
        }
    }
    
    func retake() {
        // in tutorial guy has global(qos: .background)
        DispatchQueue.global(qos: .background).async {
            self.session.startRunning()
            DispatchQueue.main.async {
                withAnimation {self.isTaken.toggle()}
                // should again be true here?
                self.isSaved = false
            }
        }
    }
    
    func takepic() {
        // it's global(qos: .background).asyncAfter(deadline: .now()+0.2) or main.async.
        // issue with couldNotCapture is that the capture session ends before the photoOutput delegate is called.
        self.output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
        DispatchQueue.main.async {
            self.session.stopRunning()
            DispatchQueue.main.async {
                withAnimation{self.isTaken.toggle()}
                // should be true here
            }
        }
//        self.session.stopRunning() // comment says maybe out here???
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: (any Error)?) {
        if error != nil {
            print("photooutput error")
            print(error!)
            self.couldNotRecord = true
            return
        }
        self.couldNotRecord = false
        print("taken")
        
        guard let imageData = photo.fileDataRepresentation() else {
            print("imagedata failed")
            return
        }
        self.picData = imageData
        
    }
    
    func savePic() {
        let image = UIImage(data: self.picData)!
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        self.isSaved = true
        print("image saved!!")
    }
    
}
