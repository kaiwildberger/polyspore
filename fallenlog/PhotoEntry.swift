//
//  PhotoEntry.swift
//  fallenlog
//
//  Created by Kai Wildberger on 12/28/24.
//

import Foundation
import SwiftData
import SwiftUI
import AVFoundation
import CoreData

@Model
class PhotoEntry: Identifiable {
    var author: String = "iOS Device"
    var timestamp: Date = Date(timeIntervalSinceReferenceDate: -123456789.0)
    var notes: String = "(no note added)"
    var image: Data = Data(count: 0)
    var id: UUID = UUID()
//    var location: UserLocation
    init(author: String, timestamp: Date, notes: String, image: Data) {
        self.author = author
        self.timestamp = timestamp
        self.notes = notes
        self.image = image
    }
}

struct PhotoEntryView: View {
    @Environment(\.modelContext) var modelContext
    @Query var entries: [PhotoEntry]
    @State private var imageIsFullscreen = false
    @State var selectedImage: UIImage?
    
    var body: some View {
        Text("Entries")
        List(entries) { entry in
            // name, timestamp, author, image
            @State var notes = ""
            HStack {
                // haven't tried if let on this one
                let uiImage: UIImage = UIImage(data: entry.image)!
//                let _ = { selectedImage = uiImage }()
                Button(action: {
                    let _ = {
                        selectedImage = UIImage(data: entry.image)!
                        print("SI initialized")
                    }()
                    imageIsFullscreen.toggle()
//                    selectedImage = uiImage
                }, label: {
                    Image(uiImage: uiImage)
                        .aspectRatio(contentMode: .fill)
                        .frame(width:80,height: 80,alignment: .center)
                        .scaleEffect(0.1)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                })
                Spacer()
                TextField("Notes", text: Bindable(entry).notes) // wrap entry with bindable so we can do this
                    .padding(.leading,10)
            }
        }
        .fullScreenCover(isPresented: $imageIsFullscreen, content: {
            ZStack {
//                            let _ = {
//                                selectedImage = UIImage(data: entry.image)!
//                                print("SI initialized")
//                            }()
                // why does it flash at the beginning
                Image(uiImage: selectedImage ?? genInitialImage())
                    .resizable()
                    .scaledToFill()
                    .onTapGesture {
                        imageIsFullscreen.toggle()
                    }
            }
            .ignoresSafeArea(.all)
        })
    }
    
    func genInitialImage() -> UIImage {
        let imageSize = CGSize(width: 420, height: 120)
        let color: UIColor = .black
        UIGraphicsBeginImageContextWithOptions(imageSize, true, 0)
        let context = UIGraphicsGetCurrentContext()!
        color.setFill()
        context.fill(CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        print("image generated")
        return image
    }
}
