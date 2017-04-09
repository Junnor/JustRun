//
//  Location+CoreDataProperties.swift
//  JustRun
//
//  Created by Ju on 2017/4/9.
//  Copyright © 2017年 Ju. All rights reserved.
//

import Foundation
import CoreData


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var timestamp: NSDate?
    @NSManaged public var run: Run?

}
