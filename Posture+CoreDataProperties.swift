//
//  Posture+CoreDataProperties.swift
//  ProperPosture
//
//  Created by Jared Franzone on 2/20/16.
//  Copyright © 2016 Jared Franzone. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Posture {

    @NSManaged var duration: NSNumber?
    @NSManaged var date: NSDate?

}
