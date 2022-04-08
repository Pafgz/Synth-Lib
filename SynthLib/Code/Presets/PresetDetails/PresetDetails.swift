//
//  NewPreset.swift
//  Synth Lib
//
//  Created by Pierre-Antoine Fagniez on 26/09/2021.
//

import SwiftUI
import Combine

struct PresetDetails: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @StateObject private var vm: PresetDetailsVm
    
    init(preset: Preset?) {
        _vm = StateObject(wrappedValue: PresetDetailsVm(currentPreset: preset)
        )
    }
    
    var body: some View {
        PresetDetailsContent(
            preset: vm.preset,
            presetName: $vm.presetName,
            newPhoto: $vm.newPhoto,
            isEditMode: $vm.isEditMode,
            images: vm.images,
            recordings: vm.recordings,
            onTapSavePreset: vm.savePreset,
            onTapAddImage: vm.storePicture,
            onTapDeleteImage: vm.deleteImage,
            onStopRecording: vm.stopRecording,
            onTapPlay: vm.togglePlayRecording,
            onTapRecord: vm.onTapRecord,
            onTapDeletePreset: {
                vm.deletePreset {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        )
    }
}

struct PresetDetailsContent: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var photoSource: UIImagePickerController.SourceType = .photoLibrary
    
    @State private var showImagePicker = false
    @State private var showNewImageSheet = false
    @State private var showRecorderSheet = false
    
    let preset: Preset?
    
    @Binding var presetName: String
    @Binding var newPhoto: UIImage?
    @Binding var isEditMode: Bool
    
    let images: [AppImageData]
    let recordings: [Recording]
    let isRecording = false
    
    let onTapSavePreset: () -> Void
    let onTapAddImage: (UIImage) -> Void
    let onTapDeleteImage: (AppImageData) -> Void
    let onStopRecording: () -> Void
    let onTapPlay: (Recording) -> Void
    let onTapRecord: () -> Void
    let onTapDeletePreset: () -> Void
    
    var body: some View {
        ZStack {
            R.color.darkBlue.color.ignoresSafeArea()
            ScrollView {
                VStack() {
                    
                    TextField("Preset Name", text: $presetName, onCommit: {
                        print("Saving preset after changing the name")
                        onTapSavePreset()
                    })
                        .foregroundColor(Color.white)
                        .font(.system(size: 32))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                        .contentShape(Rectangle())
                    
                    if(images.isEmpty) {
                        Button(action: {
                            showNewImageSheet = true
                        }) {
                            AddImageItem()
                        }
                    } else if images.count == 1 {
                        if let image = images.first {
                            PresetImage(image: image,
                                        showDeleteButton: isEditMode,
                                        onDelete: { image in onTapDeleteImage(image)
                            },
                                        onClick: { image in })
                        }
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(images) { image in
                                    PresetImage(image: image, showDeleteButton: isEditMode,
                                                onDelete: { image in
                                        onTapDeleteImage(image)
                                    }, onClick: { image in
                                    })
                                }
                            }
                        }
                    }
                }
                
                AppButton(text: "Add a picture", width: 250) {
                    showNewImageSheet = true
                }
                
                if let tagList = preset?.tagList {
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
                
                RecordingListView(recordingList: recordings) {
                    showRecorderSheet = true
                } onTapDemo: { demo in
                    onTapPlay(demo)
                } onDeleteDemo: { recording in
                    
                }
                
                Spacer()
                
                if(isEditMode) {
                    AppButton(text: "Delete Preset", bgColor: R.color.red.color) {
                        onTapDeletePreset()
                    }
                    .padding(16)
                }
                
                Spacer()
            }
        }
        .sheet(isPresented: $showImagePicker, onDismiss:{
            if let newPhoto = newPhoto {
                onTapAddImage(newPhoto)
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
            onStopRecording()
        }) {
            RecorderView(isRecording: isRecording, onClickRecord: {
                if(isRecording) {
                    showRecorderSheet = false
                }
                onTapRecord()
            })
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(leading: Button(action: {
            presentationMode.wrappedValue.dismiss()
        }, label: {
                    Image(systemName: "chevron.left")
                    .frame(width: 40, height: 40)
                    .foregroundColor(.white)
        }), trailing:
            Button(action: {
            withAnimation {
                isEditMode.toggle()
            }
            }) {
                Text("Edit")
            }
        )
    }
}

struct PresetDetails_Previews: PreviewProvider {
    static var previews: some View {
        let preset = Preset(id: UUID(), name: "Peneloppe Horns", tagList: [
            Tag(name: "Horn"),
            Tag(name: "Air"),
            Tag(name: "Pad"),
            Tag(name: "Chill"),
            Tag(name: "Melancholy")
        ])
        PresetDetailsContent(
            preset: preset,
            presetName: .constant("Flutes"),
            newPhoto: .constant(nil),
            isEditMode: .constant(true),
            images: [], recordings: [],
            onTapSavePreset: {},
            onTapAddImage: {_ in},
            onTapDeleteImage: {_ in},
            onStopRecording: {},
            onTapPlay: { _ in},
            onTapRecord: {},
            onTapDeletePreset: {}
        )
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
            ZStack {
                Button(action: { onClick(self.image) }) {
                    Image(uiImage: image)
                        .resizable()
                        .centerCropped()
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .frame(width: 250, height: 250, alignment: .center)
                        .clipped()
                }
            }
                .frame(width: 260, height: 260)
                .if(showDeleteButton) {
                    $0.overlay(Button(action: {
                        onDelete(self.image)
                    }) {
                        ZStack {
                            R.color.darkGrey.color
                            Image(systemName: "xmark")
                                .resizable()
                                .frame(width: 15, height: 15)
                        }
                    }.clipShape(Circle())
                    .frame(width: 40, height: 40, alignment:
                            .topTrailing), alignment: .topTrailing)
                    .fade()
                }
        }
    }
}

struct RecordingListView: View  {
    
    var recordingList: [Recording]
    var onTapAddRecording: () -> Void
    var onTapDemo: (Recording) -> Void
    var onDeleteDemo: (Recording) -> Void
    
    public var body: some View {
        VStack {
            Text("Sound demos")
                .font(.system(size: 28))
                .foregroundColor(Color.white)
            ForEach(recordingList, id: \.createdAt) { recording in
                Button(action: {
                    onTapDemo(recording)
                }, label: {
                    RecordingRow(recording: recording)
                })
                .swipeActions(edge: .trailing) {
                    deleteButton(recording: recording)
                }
            }
            
            AppButton(text: "Add a demo") {
                onTapAddRecording()
            }
            .frame(width: 250)
            .padding(recordingList.isEmpty ? 0 : 16)
        }
    }
    
    private func deleteButton(recording: Recording) -> some View {
        Button(action: {
            delete(recording: recording)
        }, label: {
            Text("Delete")
        })
    }
    
    func delete(recording: Recording) {
        onDeleteDemo(recording)
    }
}


struct RecordingListView_Previews: PreviewProvider {
    static var previews: some View {
        RecordingListView(recordingList: RecordingPreviewData.recordingList) {} onTapDemo: {_ in } onDeleteDemo: {_ in}
    }
}

struct RecordingRow: View  {
    
    @State var recording: Recording
    
    public var body: some View {
            HStack {
                Text(recording.fileURL.lastPathComponent)
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding(.horizontal, 16)
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
