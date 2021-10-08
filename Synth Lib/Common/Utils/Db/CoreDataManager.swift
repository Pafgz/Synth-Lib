//
//  CoreDataManager.swift
//  Synth Lib
//
//  Created by Pierre-Antoine Fagniez on 01/10/2021.
//

import Foundation
import CoreData
import UIKit
import SwiftUI

class CoreDataManager: ObservableObject {
    
    static let shared = CoreDataManager()
    
    
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores(completionHandler: { _, error in
            _ = error.map { fatalError("Unresolved error \($0)") }
        })
        return container
    }()
    
    func savePreset(preset: Preset) throws {
        if let entity = try? loadPresetEntities(
            predicate: NSPredicate(format: "presetId LIKE %@", preset.id)
        ).first {
            entity.presetId = preset.id
            entity.name = preset.name
            entity.hasDemo = NSNumber.init(value: preset.hasDemo)
            preset.tagList.forEach { tag in
                let tagEntity = createTag(tagName: tag.name, presetEntity: entity)
                entity.addToTags(tagEntity)
            }
        }
        else {
            let entity = PresetEntity(context: context())
            entity.id = UUID()
            entity.presetId = preset.id
            entity.name = preset.name
            entity.hasDemo = NSNumber.init(value: preset.hasDemo)
            preset.tagList.forEach { tag in
                let tagEntity = createTag(tagName: tag.name, presetEntity: entity)
                entity.addToTags(tagEntity)
            }
        }
        
        save(onConflict: {
            print("Conflicts saving \(preset.name)")
        })
        print("Saved \(preset.name)")
    }
    
    func createTag(tagName: String, presetEntity: PresetEntity?) -> TagEntity {
        let entity = createTag(tagName: tagName)
        if let presetEntity = presetEntity {
            entity.addToPresets(presetEntity)
        }
        return entity
    }
    
    func createTag(tagName: String, presetEntities: [PresetEntity]?) -> TagEntity  {
        let entity = createTag(tagName: tagName)
        if let presetEntities = presetEntities {
            presetEntities.forEach { preset in
                entity.addToPresets(preset)
            }
        }
        return entity
    }
    
    private func createTag(tagName: String) -> TagEntity {
        if let entity = try? loadTagEntities(predicate: NSPredicate(format: "name LIKE %@", tagName)).first {
            entity.name = tagName
            print("Tag \(tagName) updated")
            return entity
        } else {
            let entity = TagEntity(context: context())
            entity.id = UUID()
            entity.name = tagName
            print("Tag \(tagName) created")
            return entity
        }
    }
    
    func loadPresets() throws -> [Preset] {
        return try loadPresets(predicate: nil)
    }
    
    func loadPresets(with id: String) throws -> [Preset] {
        return try loadPresetWithFilter(key: "presetId", value: id)
    }
    
    func loadPresets(named name: String) throws -> [Preset] {
        return try loadPresetWithFilter(key: "name", value: name)
    }
    
    private func loadPresetWithFilter(key: String, value: String) throws -> [Preset] {
        return try loadPresets(predicate: NSPredicate(format: "\(key) LIKE %@", value))
    }
    
    private func loadPresets(predicate: NSPredicate? = nil) throws -> [Preset] {
        return try loadPresetEntities(predicate: predicate).compactMap { entity in
            entity.asPreset
        }
    }
    
    
    
    private func loadPresetEntities(predicate: NSPredicate? = nil) throws -> [PresetEntity] {
        let request = PresetEntity.fetchRequest()
        
        if let predicate = predicate {
            request.predicate = predicate
        }
        
        return try context().fetch(request)
    }
    
    private func loadTagEntities(predicate: NSPredicate? = nil) throws -> [TagEntity] {
        let request = TagEntity.fetchRequest()
        
        if let predicate = predicate {
            request.predicate = predicate
        }
        
        return try context().fetch(request)
    }
    
    func save(onConflict: (() -> Void)?) {
        guard context().hasChanges else { return }
        do {
            try context().save()
        } catch let error as NSConstraintConflict {
            if let onConflict = onConflict {
                onConflict()
                print("Error: \(error)")
            }
        }
        catch let error as NSError {
            print("Error: \(error), \(error.userInfo)")
        }
    }
    
    func backgroundContext() -> NSManagedObjectContext {
        return container.newBackgroundContext()
    }
    
    func context() -> NSManagedObjectContext {
        return container.viewContext
    }
}

extension PresetEntity {
    public var tagList: [TagEntity] {
         if let tags = tags {
            return tags.allObjects as! Array<TagEntity>
        } else {
            return []
        }
    }

    var asPreset: Preset? {
        if let id = presetId {
            return Preset(id: id, name: presetName, hasDemo: hasDemo?.boolValue ?? false)
        } else {
            return nil
        }
    }
    
    var presetName: String {
        return name ?? "Unnamed Preset"
    }
}

extension TagEntity {
    public var presetList: [PresetEntity] {
        if let presets = presets {
            return presets.allObjects as! Array<PresetEntity>
        } else {
            return []
        }
    }

    var asTag: Tag? {
        if let id = id {
            return Tag(id: id, name: tagName)
        } else {
            return nil
        }
    }
    
    var tagName: String {
        return name ?? "Unnamed Tag"
    }
}
