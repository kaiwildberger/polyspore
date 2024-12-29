//
//  ContentView.swift
//  fallenlog
//
//  Created by Kai Wildberger on 12/27/24.
//

import SwiftUI
import SwiftData
import AVFoundation // probably necessary here

/**
 
 - Add family name annotations (Amanitaceae)
 - Possibly prompts for cap/stipe/gill characteristics
 - Tags as discrete categories
 - Add modal Edit view to Entries
 + Make camera button bigger
    + looks like shit but it works
 + add Back button before image is captured
    - redesign Back button (different icon or something)
 - the fullscreencover is linked to the list element, not the picture. potentially Annoying feature.
    - Or i rework the way we view images with the modal Edit pane
 
 
 */




struct ExportSettings {
    var exportName: String
    init(exportName: String = UIDevice.current.name) {
        self.exportName = exportName
    }
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    var exportSettings = ExportSettings()
    
    @State var exportName: String = UIDevice.current.name
    @Query var entries: [PhotoEntry]
    
    var body: some View {
        NavigationView {
            ZStack {
                PhotoEntryView()
                CameraView()
            }
            .toolbar {
                ToolbarItem {
                    NavigationLink {
                        Text("export yuor data!!!")
                    } label: {
                        Button(action: {}) {
                            Label("Export", systemImage: "square.and.arrow.up")
                        }
                    }
                }
                ToolbarItem {
                    NavigationLink {
                        // settings page
                        VStack {
                            Text("Settings")
                            List {
                                HStack {
                                    Text("Name on export")
                                    TextField("Export name", text: $exportName)
                                }
                            }
                            Button(action: { exportData(settings: exportSettings)}, label: {
                                Text("Export")
                                    .bold()
                                    .foregroundStyle(Color.black)
                                    .background(Color.blue)
                                    .padding(.vertical,10)
                                    .padding(.horizontal,10)
                                    .clipShape(.capsule)
                            })
                        }
                        // export mostly
                        // name on export (for labelling entries)
                    } label: {
                        Button(action: populateSettings) {
                            Label("Options", systemImage: "gearshape")
                        }
                    }
                }
            }
        }
    }
    
    func exportData(settings: ExportSettings) {
        print("yayy data exported :p")
    }
    
    func populateSettings() {
        // remember this from vassalize.
        // i have to populate the fields with the stored settings??
    }
}

#Preview {
    ContentView()
}
