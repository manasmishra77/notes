//
//  NoteMO+CoreDataProperties.swift
//  Notes
//
//  Created by Nauroo on 09/04/17.
//  Copyright © 2017 Manas. All rights reserved.
//

import Foundation
import CoreData


extension NoteMO {

    @nonobjc public class func modelFetchRequest() -> NSFetchRequest<NoteMO> {
        return NSFetchRequest<NoteMO>(entityName: "Note");
    }

    @NSManaged public var tag: String?
    @NSManaged public var detail: String?
    @NSManaged public var updatedAt: NSDate?

}
