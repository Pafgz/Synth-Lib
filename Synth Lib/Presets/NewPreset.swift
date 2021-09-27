//
//  NewPreset.swift
//  Synth Lib
//
//  Created by Pierre-Antoine Fagniez on 26/09/2021.
//

import SwiftUI

struct NewPreset: View {
    
    @State private var showImagePicker = false
    @State private var showNewImageSheet = false
    @State private var newPhoto: UIImage?
    @State private var photoSource: UIImagePickerController.SourceType = .photoLibrary
    
    var body: some View {
    
        VStack() {
            Text("Save a new preset")
                .font(.system(size: 38))
            
            Text("Pictures")
                .font(.system(size: 32))
                .padding(.top, 16)
            if let newPhoto = newPhoto {
                Image(uiImage: newPhoto)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 300, height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            } else {
                Button(action: {
                    showNewImageSheet = true
                }) {
                    AddImageItem()
                        .frame(width: 300, height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            }
            
            
            Text("Sound demos")
                .font(.system(size: 32))
                .padding(.top, 16)
            Spacer()
        }
        .sheet(isPresented: $showImagePicker, onDismiss: {}, content: {
            ImagePicker(sourceType: photoSource, image: $newPhoto)
        })
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
        .padding(16)
    }
}

struct NewPreset_Previews: PreviewProvider {
    static var previews: some View {
        NewPreset()
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
//        .onAppear(perform: image.fetch)
//        .onDisappear(perform: image.cancel)
    }
}


struct AddImageItem_Previews: PreviewProvider {
    static var previews: some View {
        AddImageItem()
    }
}
