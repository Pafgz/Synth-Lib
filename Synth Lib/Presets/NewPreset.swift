//
//  NewPreset.swift
//  Synth Lib
//
//  Created by Pierre-Antoine Fagniez on 26/09/2021.
//

import SwiftUI

struct NewPreset: View {
    
    @ObservedObject var newPresetVm = NewPresetVm()
    @EnvironmentObject var localStorage: LocalStorage
    @State private var showImagePicker = false
    @State private var showNewImageSheet = false
    @State private var newPhoto: UIImage?
    @State private var photoSource: UIImagePickerController.SourceType = .photoLibrary
    
    var body: some View {
    
        VStack() {
            Text("Save a new preset")
                .font(.system(size: 32))
                .padding(.top, 64)

            if(newPresetVm.images.isEmpty) {
                Button(action: {
                    showNewImageSheet = true
                }) {
                    AddImageItem()
                        .frame(width: 250, height: 250)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            } else if (newPresetVm.images.count == 1) {
                PresetImage(viewImage: newPresetVm.images.first)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(newPresetVm.images, id: \.id) { photo in
                            Button(action: {

                            }) {
                                PresetImage(viewImage: photo)
                            }
                        }
                    }
                }.padding(.horizontal, 16)
            }
            
            Button(action: {
                showNewImageSheet = true
            }) {
                AppButton(text: "Add a picture", bgColor: Color.green)
                    .padding(16)
            }
            
            Text("Sound demos")
                .font(.system(size: 28))
                .padding(.top, 8)
            
            Spacer()
        }
        .sheet(isPresented: $showImagePicker, onDismiss:{
            if let newPhoto = newPhoto {
                newPresetVm.savePicture(inputImage: newPhoto)
            }
        }) {
            ImagePicker(sourceType: photoSource, image: $newPhoto)
        }
        .actionSheet(isPresented: $showNewImageSheet) {
            ActionSheet(title: Text("Add a new image"), message: Text("Select a method"), buttons: [
                .default(Text("Take a picture")) {
                    photoSource = .camera
                    showImagePicker = true
                },
                .default(Text("Open photos")) {
                    photoSource = .photoLibrary
                    showImagePicker = true
                },
                .cancel()
            ])
        }
        .ignoresSafeArea()
    }
}

struct NewPreset_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NewPreset()
                .previewDevice(PreviewDevice(rawValue: "iPhone 6s"))
                              .previewDisplayName("iPhone 6s")
        }
    }
}

struct AddImageItem: View  {
 
    public var body: some View {
        GeometryReader { proxy in
            ZStack {
                Rectangle()
                
                Image(systemName: "plus")
                    .resizable()
                    .scaledToFill()
                    .padding(.all, 64)
                    .foregroundColor(Color.white)
                    .background(Color.gray.opacity(0.99))
            }
        }
    }
}


struct AddImageItem_Previews: PreviewProvider {
    static var previews: some View {
        AddImageItem()
    }
}

struct PresetImage: View  {
 
    var viewImage: ViewImage? = nil
    
    public var body: some View {
        if let image = viewImage?.image {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 250, height: 250)
                .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
}
