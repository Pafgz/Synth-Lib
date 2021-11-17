//
//  PhotoEntity+CoreDataProperties.swift
//  Synth Lib
//
//  Created by Pierre-Antoine Fagniez on 05/10/2021.
//
//

import Foundation
import CoreData


extension PhotoEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PhotoEntity> {
        return NSFetchRequest<PhotoEntity>(entityName: "PhotoEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var data: Data?
    @NSManaged public var preset: PresetEntity?

}

extension PhotoEntity : Identifiable {

}
