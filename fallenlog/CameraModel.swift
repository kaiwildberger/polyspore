class CameraModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate, CLLocationManagerDelegate {
//    @Environment(\.modelContext) var modelContext
//    let managedContext = NSManagedObject(context: context)
    var modelContext: ModelContext?
    var locmgr = CLLocationManager()
    
    @Published var isTaken = false;
    @Published var session = AVCaptureSession()
    @Published var alert = false;
    @Published var output = AVCapturePhotoOutput()
    @Published var preview: AVCaptureVideoPreviewLayer!
    @Published var picData = Data(count: 0)
    @Published var isSaved = false
    @Published var couldNotRecord = false
    @Published var photoEntry: PhotoEntry?
    @Query var appSettings: [AppSettings]
    
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
            print("photooutput error \(error!)")
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
        locmgr.delegate = self
        locmgr.requestLocation()
        locmgr.requestWhenInUseAuthorization()
        
        if let context = modelContext { // maybe i think this is Supposed to Be a cool sexy DataManager class that does this all for me, but...
            let accuracyThreshold = appSettings[0].locationAccuracyThreshold
            print("accuracythreshold is \(accuracyThreshold)")
            // i'm hoping this coalesces if location denied; when i test denied location is this the solution? (yes, yes it is)
            var current = locmgr.location ?? CLLocation(latitude: 0.0, longitude: 0.0)
            while current.horizontalAccuracy > accuracyThreshold { // eventually this should be AppSettings.locationAccuracyThreshold
                current = locmgr.location!
            }
            let photoEntry = PhotoEntry(author: "iOS Device", timestamp: Int(Date().timeIntervalSince1970), notes: "", image: self.picData, location: LocationWrapper(full: current.coordinate, alt: current.altitude, acc: current.horizontalAccuracy).expand())
            // current.horizontalAccuracy
            print("location: \(LocationWrapper(full: current.coordinate, alt: current.altitude, acc: current.horizontalAccuracy).expand())")
            context.insert(photoEntry)
            do { try context.save()
                print("\(photoEntry.image) saved")
                self.isSaved = true
            } catch { print("ERROR: ", error) }
            
            // open DetailEditView with new photoEntry
            
        } else {
            // Make sure you have a way to know if you are failing to access the context
            print("New Context is Nil!")
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.first != nil {
            print("location :: \(locations.first)")
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("locationmanager error :: \(error.localizedDescription)")
    }
}
