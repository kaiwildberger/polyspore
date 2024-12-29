//
//  CameraView.swift
//  fallenlog
//
//  Created by Kai Wildberger on 12/29/24.
//

import SwiftUI
import SwiftData
import AVFoundation

struct CameraView: View {
    @Environment(\.dismiss) var dismiss
    @State private var isShowingCamera = false
    @StateObject var camera = CameraModel()
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    isShowingCamera.toggle()
                    camera.isSaved = false
                    camera.isTaken = false
                }, label: {
                    VStack {
                        Spacer()
                        Image(systemName: "camera.viewfinder")
                            .frame(width:100,height:100)
//                            .imageScale(.large)
                            .font(.title)
                            .background(Color.green)
                            .clipShape(Circle())
                    }
                })
                .frame(width:100,height:100)
                .shadow(radius: 2)
                .padding(.all, 30)
                .fullScreenCover(isPresented: $isShowingCamera, onDismiss: cameraDismissed, content: {
                    ZStack {
                        CameraPreview(camera: camera)
                        //            Color.black
                            .ignoresSafeArea(.all, edges: .all)
                        VStack {
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
                                Spacer()
                                if camera.isTaken {
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
                                    Button(action: {
                                        if !camera.isSaved{
                                            camera.modelContext = modelContext
                                            camera.savePic()
                                            isShowingCamera.toggle()
                                        }
                                    }, label: {
                                        Text(camera.isSaved ? "Saved":"Save")
                                            .foregroundStyle(Color.black)
                                            .fontWeight(.semibold)
                                            .padding(.vertical,10)
                                            .padding(.horizontal,20)
                                            .background(Color.white)
                                            .clipShape(.capsule)
                                    })
                                    .padding(.leading)
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
        } // vstack
    }
    public func cameraDismissed() {
        camera.session.stopRunning()
        camera.isTaken = false
    }
    func saveAndAdd() {
//        camera.photoEntry = PhotoEntry(author: "iOS Device", timestamp: Date.now, notes: "exciting", image: Data(count: 0))
//        camera.modelContext.insert(camera.photoEntry!)
        do {
            try modelContext.save()
            isShowingCamera.toggle()
            cameraDismissed()
        } catch {
            print("adding to modelcontext failed again")
        }
        camera.savePic()
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
            
            DispatchQueue.global(qos:.background).async {
                camera.session.startRunning()
            }
        }
        
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}

class CameraModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
//    @Environment(\.modelContext) var modelContext
//    let managedContext = NSManagedObject(context: context)
    var modelContext: ModelContext?
    @Published var isTaken = false;
    @Published var session = AVCaptureSession()
    @Published var alert = false;
    @Published var output = AVCapturePhotoOutput()
    @Published var preview: AVCaptureVideoPreviewLayer!
    @Published var picData = Data(count: 0)
    @Published var isSaved = false
    @Published var couldNotRecord = false
    @Published var photoEntry: PhotoEntry?
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
        guard let imageData = photo.fileDataRepresentation() else {
            print("imagedata failed")
            return
        }
        self.picData = imageData
    }
    
    func savePic() {
        //        let image = UIImage(data: self.picData)!
        //        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        if let context = modelContext {
            let photoEntry = PhotoEntry(author: "iOS Device", timestamp: Date.now, notes: "", image: self.picData)
            context.insert(photoEntry)
            do { try context.save()
                print("\(photoEntry.image) saved")
                self.isSaved = true
            } catch { print("ERROR: ", error) }
        } else {
            // Make sure you have a way to know if you are failing to access the context
            print("New Context is Nil!")
        }
    }
    
}
