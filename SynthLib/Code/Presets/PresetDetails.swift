//
//  NewPreset.swift
//  Synth Lib
//
//  Created by Pierre-Antoine Fagniez on 26/09/2021.
//

import SwiftUI
import Combine

struct PresetDetails: View {
    
    var preset: Preset
    
    @ObservedObject var vm = PresetDetailsVm()
    @EnvironmentObject var localStorage: LocalStorage
    @EnvironmentObject var dbManager: CoreDataManager
    
    @State private var showImagePicker = false
    @State private var showNewImageSheet = false
    @State private var showRecorderSheet = false
    
    @State private var newPhoto: UIImage?
    @State private var newRecording: Recording?
    
    @State private var photoSource: UIImagePickerController.SourceType = .photoLibrary
    
    @State private var isEditMode = false
    @State private var isDeleted = false
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        
        let presetName: Binding<String> = Binding { () -> String in
            return vm.preset?.name ?? "No name"
        } set: { value in
            print("Changing name with " + value)
            vm.updateName(name: value)
        }
        
        ZStack {
            R.color.darkBlue.color.ignoresSafeArea()
            ScrollView {
                VStack() {
                    TextField("Preset Name", text: presetName, onCommit: {
                        print("Saving preset after changing the name")
                        vm.savePreset()
                    })
                        .foregroundColor(Color.white)
                        .font(.system(size: 32))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                        .contentShape(Rectangle())
                    
                    if(vm.images.isEmpty) {
                        Button(action: {
                            showNewImageSheet = true
                        }) {
                            AddImageItem()
                        }
                    } else if vm.images.count == 1 {
                        if let image = vm.images.first {
                            PresetImage(image: image,
                                        showDeleteButton: isEditMode,
                                        onDelete: { image in vm.deleteImage(image: image)
                            },
                                        onClick: { image in })
                        }
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(vm.images) { image in
                                    PresetImage(image: image, showDeleteButton: isEditMode,
                                                onDelete: { image in
                                        vm.deleteImage(image: image)
                                        
                                    },
                                                onClick: { image in
                                        
                                    })
                                }
                            }
                        }
                    }
                }
                
                AppButton(text: "Add a picture", width: 250) {
                    showNewImageSheet = true
                }
                
                if let tagList = vm.preset?.tagList {
                    if (!tagList.isEmpty) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            List() {
                                ForEach(tagList) { tag in
                                    TagView(tag: tag) { _ in }
                                }
                            }
                        }.padding(.horizontal, 16)
                    }
                }
                
                Spacer()
                
                RecordingListView(recordingList: vm.recordings) {
                    showRecorderSheet = true
                } onClickDemo: { demo in
                    vm.playSound(recording: demo)
                }
                
                Spacer()
                
                if(isEditMode) {
                    AppButton(text: "Delete Preset", bgColor: R.color.red.color) {
                        isDeleted = vm.deletePreset()
                        if(isDeleted) {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    .padding(16)
                }
                
                Spacer()
            }
        }
        .sheet(isPresented: $showImagePicker, onDismiss:{
            if let newPhoto = newPhoto {
                vm.storePicture(inputImage: newPhoto)
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
        .sheet(isPresented: $showRecorderSheet, onDismiss: {
            vm.stopRecording()
        }) {
            RecorderView(isRecording: vm.isRecording, onClickRecord: {
                if(vm.isRecording) {
                    showRecorderSheet = false
                }
                vm.clickRecord()
            })
        }
        .navigationBarItems(trailing:
                                Button(action: {
            isEditMode = !isEditMode
        }) {
            Text("Edit")
        })
        .onAppear(perform: {
            print(preset.name)
            vm.setup(coreDataManager: dbManager, currentPreset: preset)
        })
    }
}

struct PresetDetails_Previews: PreviewProvider {
    static var previews: some View {
        let db = CoreDataManager.shared
        Group {
            PresetDetails(preset: PresetPreviewData.preset1)
                .previewDevice(PreviewDevice(rawValue: "iPhone 6s"))
                .previewDisplayName("iPhone 6s")
                .environmentObject(db)
        }
    }
}

struct PresetDetailsWithPreset_Previews: PreviewProvider {
    static var previews: some View {
        let db = CoreDataManager.shared
        let preset = Preset(id: UUID(), name: "Peneloppe Horns", tagList: [
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
                    .background(R.color.lightGrey.color)
            }
        }
        .frame(width: 250, height: 250, alignment: .center)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}


struct AddImageItem_Previews: PreviewProvider {
    static var previews: some View {
        AddImageItem()
    }
}

struct PresetImage: View  {
    
    var image: AppImageData
    var showDeleteButton = false
    var onDelete: (AppImageData) -> Void
    var onClick: (AppImageData) -> Void
    
    public var body: some View {
        if let image = image.asUIImage() {
            let imageView = ZStack {
                Button(action: { onClick(self.image) }) {
                    Image(uiImage: image)
                        .resizable()
                        .centerCropped()
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .frame(width: 250, height: 250, alignment: .center)
                        .clipped()
                }
            }.frame(width: 260, height: 260)
            
            if(showDeleteButton) {
                imageView.overlay(Button(action: {
                    onDelete(self.image)
                }) {
                    ZStack {
                        R.color.darkGrey.color
                        Image(systemName: "xmark")
                            .resizable()
                            .frame(width: 15, height: 15)
                    }
                }.clipShape(Circle())
                                    .frame(width: 40, height: 40, alignment: .topTrailing), alignment: .topTrailing)
            } else {
                imageView
            }
        }
    }
}

struct RecordingListView: View  {
    
    var recordingList: [Recording]
    var onClickAddRecording: () -> Void
    var onClickDemo: (Recording) -> Void
    
    public var body: some View {
        VStack {
            Text("Sound demos")
                .font(.system(size: 28))
                .foregroundColor(Color.white)
            ForEach(recordingList, id: \.createdAt) { recording in
                Button(action: {
                    onClickDemo(recording)
                }) {
                    RecordingRow(recording: recording)
                }
            }
            
            AppButton(text: "Add a demo") {
                onClickAddRecording()
            }.frame(width: 250)
        }
    }
}


struct RecordingListView_Previews: PreviewProvider {
    static var previews: some View {
        RecordingListView(recordingList: RecordingPreviewData.recordingList) {} onClickDemo: {_ in }
    }
}

struct RecordingRow: View  {
    
    @State var recording: Recording
    
    public var body: some View {
            HStack {
                Text(recording.fileURL.lastPathComponent)
                    .foregroundColor(.white)
                
                Spacer()
            }.padding(.horizontal, 16)
            .frame(height: 40)
            .background(R.color.darkGrey.color)
    }
}


struct RecordingRow_Previews: PreviewProvider {
    static var previews: some View {
        RecordingRow(recording: RecordingPreviewData.recording1)
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

struct RecordingPreviewData {
    static let recording1: Recording = Recording(fileURL: URL(fileURLWithPath: "Test"), createdAt: Date())
    static let recording2: Recording = Recording(fileURL: URL(fileURLWithPath: "Check "), createdAt: Date())
    static let recording3: Recording = Recording(fileURL: URL(fileURLWithPath: "Pad"), createdAt: Date())
    static let recording4: Recording = Recording(fileURL: URL(fileURLWithPath: "Stacato"), createdAt: Date())
    
    static let recording5 = Recording(fileURL: URL(fileURLWithPath: "Speed test"), createdAt: Date())
    
    static let recordingList: [Recording] = [recording1, recording2, recording3, recording4]
}
