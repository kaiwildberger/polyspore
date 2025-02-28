//
//  DetailEditView.swift
//  fallenlog
//
//  Created by Kai Wildberger on 1/6/25.
//

import SwiftUI
import SwiftData
import CoreLocation
import MapKit

struct DetailEditView: View {
    // this will be supplied Later by the click event
//    @State private var entry: PhotoEntry = emptyEntry()
    @Bindable var entry: PhotoEntry
    var doneButton : () -> Void
    
    init(entry: PhotoEntry, doneButton: @escaping () -> Void) {
        self.entry = entry
        self.doneButton = doneButton
        print("hit \(self.entry.notes)")
    }
    
    var body: some View {
        return (
            VStack {
                HStack {
                    Spacer()
                    Button("Done", action: doneButton)
                        .buttonStyle(BorderlessButtonStyle())
                        .padding(.trailing, 24)
                        .padding(.top, 12)
                        .fontWeight(.bold)
                }
                Form {
                    Section {
                        let _ = {
                            print("displayed \(entry.notes)")
                        }
                        let uiImage: UIImage = UIImage(data: entry.image) ?? genInitialImage()
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
//                            .frame(maxWidth: 80, maxHeight: 80)
                        TextField("Notes", text: $entry.notes, axis: .vertical)
                            .lineLimit(4, reservesSpace: true)
                        // geo information Yeah
                    }
                    .padding(.bottom, 10)
                    Section(header: Text("Mushroom data")) {
                        Picker("Family", selection: $entry.family) {
                            ForEach(FamilyClassification.allCases) { family in
                                Text(family.rawValue.capitalized)
                            }
                        }
                    }
                    Section(header: Text("Cap description")) {
                        Picker("Shape", selection: $entry.mushroomData.capShape) {
                            ForEach(CapShapeClassification.allCases) { shape in
                                Text(shape.rawValue.capitalized)
                            }
                        }
                        TextField("Measurements", text: $entry.mushroomData.capMeasurements)
                        TextField("Color", text: $entry.mushroomData.capColor)
                        TextField("Stain", text: $entry.mushroomData.capStain)
                        TextField("Texture", text: $entry.mushroomData.capTexture)
                        TextField("Margin", text: $entry.mushroomData.capMargin)
                    }
                    Section(header: Text("Stipe description")) {
                        Picker("Shape", selection: $entry.mushroomData.stipeShape) {
                            ForEach(StipeShapeClassification.allCases) { shape in
                                Text(shape.rawValue.capitalized)
                            }
                        }
                        TextField("Measurements", text: $entry.mushroomData.stipeMeasurements)
                        TextField("Color", text: $entry.mushroomData.stipeColor)
                        TextField("Stain", text: $entry.mushroomData.stipeStain)
                        TextField("Texture", text: $entry.mushroomData.stipeTexture)
                        TextField("Interior", text: $entry.mushroomData.stipeInterior)
                    }
                    Section(header: Text("Location information")) {
                        VStack {
                            // location was denied or specifically off for this entry
                            if entry.location[0] == 0.00 && entry.location[1] == 0.00 && entry.location[2] == 0.00 {
                                Text("No location data :(")
                            } else {
                                HStack {
                                    Text("Lat / Lon")
                                    Text("\(entry.location[0]), \(entry.location[1])")
                                }
                                HStack {
                                    Text("Altitude")
                                    Text("\(entry.location[2])")
                                    Text("Accuracy")
                                    Text("\(entry.location[3])")
                                }
                                HStack {
                                    Button(action: {
                                        let latitude: CLLocationDegrees = entry.location[0]
                                        let longitude: CLLocationDegrees = entry.location[1]
                                        let regionDistance:CLLocationDistance = 10000
                                        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
                                        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
                                        let options = [
                                            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                                            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
                                        ]
                                        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
                                        let mapItem = MKMapItem(placemark: placemark)
                                        mapItem.name = entry.family.rawValue
                                        mapItem.openInMaps(launchOptions: options)
                                    }, label: {
                                        HStack {
                                            Image(systemName: "map")
                                                .foregroundStyle(Color.black)
                                                .padding()
                                                .background(Color.white)
                                            Text("Open in Maps")
                                        }
                                    })
                                }
                            }
                        }
                    }
                }
            }
        )
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
