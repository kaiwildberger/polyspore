//
//  PhotoEntryView.swift
//  fallenlog
//
//  Created by Kai Wildberger on 2/23/25.
//
import SwiftUI
import SwiftData

struct PhotoEntryView: View {
    @Environment(\.modelContext) var modelContext
    @Query var entries: [PhotoEntry]
    @State private var imageIsFullscreen = false
    @State var isPresentingEditView = false
    @State private var selectedEntry: PhotoEntry?
    
    var body: some View {
        Text("Entries")
        List {
            ForEach(entries) { entry in
                // name, timestamp, author, image
                NavigationLink {
                    DetailEditView(entry: entry)
                } label: {
                    HStack {
                        // haven't tried if let on this one
                        //                let _ = { selectedImage = uiImage }()
                        Image(uiImage: UIImage(data: entry.image)!)
                            .aspectRatio(contentMode: .fill)
                            .frame(width:80,height: 80,alignment: .center)
                            .scaleEffect(0.1)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        Spacer()
                        Text(entry.family.rawValue.capitalized)
                            .padding(.leading,10)
                    }
                }
                .swipeActions {
                    Button("Delete", systemImage: "trash") {
                        modelContext.delete(entry)
                        do { try modelContext.save()
                            print("deletion saved!")
                        } catch { print("ERROR: ", error) }
                    }
                    .tint(.red)
                }
            }
        }
        // rip sheet 2024-2025
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
