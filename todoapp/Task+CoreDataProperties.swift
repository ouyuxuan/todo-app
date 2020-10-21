//
//  Task+CoreDataProperties.swift
//  
//
//  Created by Ou Yu Xuan on 2020-10-20.
//
//

import Foundation
import CoreData


extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

    @NSManaged public var createdOn: Date?
    @NSManaged public var done: Bool
    @NSManaged public var priority: Int32
    @NSManaged public var text: String?
    @NSManaged public var updatedOn: Date?
    @NSManaged public var uuid: String?
    @NSManaged public var userid: String?

}
