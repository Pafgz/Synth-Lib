//
//  NewPreset.swift
//  Synth Lib
//
//  Created by Pierre-Antoine Fagniez on 26/09/2021.
//

import SwiftUI
import Combine

struct PresetDetails: View {
    
    var preset: Preset? = nil
    
    @ObservedObject var vm = PresetDetailsVm()
    @EnvironmentObject var localStorage: LocalStorage
    @EnvironmentObject var dbManager: CoreDataManager
    
    @State private var showImagePicker = false
    @State private var showNewImageSheet = false
    @State private var newPhoto: UIImage?
    @State private var photoSource: UIImagePickerController.SourceType = .photoLibrary
    
    @State private var hasEdited = false
    
    //Needed just because if the textfield is the first view, we can't click on it
    @State private var fieldValue = ""
    
    var body: some View {
        
        let presetName: Binding<String> = Binding { () -> String in
            return vm.preset.name
        } set: { value in
            vm.preset.name = value
            vm.hasChanges = true
        }
        
        ScrollView {
            VStack() {
                
                TextField("", text: $fieldValue)
                    .padding(.top, 40)
                
                TextField("Preset Name", text: presetName)  { result in
                    print("\(result) and \(presetName)")
                }
                .font(.system(size: 32))
                .padding(.top, 10)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                .multilineTextAlignment(.center)
                
                if(vm.images.isEmpty) {
                    Button(action: {
                        showNewImageSheet = true
                    }) {
                        AddImageItem()
                            .frame(width: 250, height: 250)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                } else if (vm.images.count == 1) {
                    PresetImage(viewImage: vm.images.first)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(vm.images) { image in
                                Button(action: {
                                    
                                }) {
                                    PresetImage(viewImage: image)
                                }
                            }
                        }
                    }.padding(.horizontal, 16)
                }
                
                if (!vm.preset.tagList.isEmpty) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        List() {
                            ForEach(vm.preset.tagList) { tag in
                                TagView(tag: tag) { _ in }
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
        }.sheet(isPresented: $showImagePicker, onDismiss:{
            if let newPhoto = newPhoto {
                vm.addPhotoToPreset(inputImage: newPhoto)
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
        .navigationBarItems(trailing: HStack {
            if(vm.hasChanges) {
                Button(action: {
                    vm.savePreset()
                }) {
                    Text("Save")
                }
            } else {
                Spacer()
            }
        })
        .onAppear {
            vm.setup(coreDataManager: dbManager, currentPreset: preset)
        }
        .ignoresSafeArea()
    }
}

struct PresetDetails_Previews: PreviewProvider {
    static var previews: some View {
        let db = CoreDataManager.shared
        Group {
            PresetDetails()
                .previewDevice(PreviewDevice(rawValue: "iPhone 6s"))
                .previewDisplayName("iPhone 6s")
                .environmentObject(db)
        }
    }
}

struct PresetDetailsWithPreset_Previews: PreviewProvider {
    static var previews: some View {
        let db = CoreDataManager.shared
        let preset = Preset(id: "43725rtyegiw", name: "Peneloppe Horns", tagList: [
            Tag(name: "Horn"),
            Tag(name: "Air"),
            Tag(name: "Pad"),
            Tag(name: "Chill"),
            Tag(name: "Melancholy")
        ])
        Group {
            PresetDetails(preset: preset)
                .previewDevice(PreviewDevice(rawValue: "iPhone 6s"))
                .previewDisplayName("iPhone 6s")
                .environmentObject(db)
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

struct TagView: View  {
    
    var tag: Tag
    var onClick: (Tag) -> Void
    
    public var body: some View {
        Button(action: {
            onClick(tag)
        }) {
            Text(tag.name)
                .foregroundColor(Color.white)
                .padding(6)
                .background(Color.gray)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}


struct TagView_Previews: PreviewProvider {
    static var previews: some View {
        TagView(tag: Tag(name: "Moody Horns")) { _ in }
    }
}
