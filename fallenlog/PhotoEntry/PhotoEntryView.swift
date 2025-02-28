//
//  PhotoEntryView.swift
//  fallenlog
//
//  Created by Kai Wildberger on 2/23/25.
//


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
                @State var notes = ""
                HStack {
                    // haven't tried if let on this one
                    //                let _ = { selectedImage = uiImage }()
                    Image(uiImage: UIImage(data: entry.image)!)
                        .aspectRatio(contentMode: .fill)
                        .frame(width:80,height: 80,alignment: .center)
                        .scaleEffect(0.1)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    Spacer()
                    Button(action: {
                        selectedEntry = entry
                        isPresentingEditView.toggle()
                    }, label: {
                        //                TextField("Notes", text: Bindable(entry).notes) // wrap entry with bindable so we can do this
                        Text(entry.family.rawValue.capitalized)
                            .padding(.leading,10)
                    })
                }
                .swipeActions {
                    Button("Delete", systemImage: "trash") {
                        modelContext.delete(entry)
                    }
                    .tint(.red)
                }
            }
            .sheet(isPresented: $isPresentingEditView) {
                let _ = {
                    print("\(selectedEntry?.notes) showing now")
                }
//                if selectedEntry == emptyEntry() {
//                    let _ = {
//                        selectedEntry = entries[0]
//                        print("changed SI")
//                    }
//                }
                DetailEditView(entry: selectedEntry!, doneButton: { isPresentingEditView.toggle() })
            }
        }
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
