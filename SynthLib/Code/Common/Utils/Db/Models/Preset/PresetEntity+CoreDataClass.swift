//
//  PresetEntity+CoreDataClass.swift
//  Synth Lib
//
//  Created by Pierre-Antoine Fagniez on 05/10/2021.
//
//

import Foundation
import CoreData

@objc(PresetEntity)
public class PresetEntity: NSManagedObject {

}


extension PresetEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PresetEntity> {
        return NSFetchRequest<PresetEntity>(entityName: "PresetEntity")
    }

    @NSManaged public var hasDemo: Bool
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var presetId: String?
    @NSManaged public var tags: NSSet?
    @NSManaged public var photos: NSSet?

    public var presetName: String {
        name ?? "Unnamed preset"
    }
    
    public var tagList: [TagEntity] {
        let set = tags as? Set<TagEntity> ?? []
        return set.sorted {
            $0.name < $1.name
        }
    }
    
    public var photoList: [PhotoEntity] {
        let set = photos as? Set<PhotoEntity> ?? []
        return set.sorted {
            $0.id < $1.id
        }
    }
}

// MARK: Generated accessors for tag
extension PresetEntity {

    @objc(addTagObject:)
    @NSManaged public func addToTag(_ value: TagEntity)

    @objc(removeTagObject:)
    @NSManaged public func removeFromTag(_ value: TagEntity)

    @objc(addTag:)
    @NSManaged public func addToTag(_ values: NSSet)

    @objc(removeTag:)
    @NSManaged public func removeFromTag(_ values: NSSet)

}

// MARK: Generated accessors for photo
extension PresetEntity {

    @objc(addPhotoObject:)
    @NSManaged public func addToPhoto(_ value: PhotoEntity)

    @objc(removePhotoObject:)
    @NSManaged public func removeFromPhoto(_ value: PhotoEntity)

    @objc(addPhoto:)
    @NSManaged public func addToPhoto(_ values: NSSet)

    @objc(removePhoto:)
    @NSManaged public func removeFromPhoto(_ values: NSSet)

}

extension PresetEntity : Identifiable {

}
