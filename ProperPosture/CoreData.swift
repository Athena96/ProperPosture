

// Author:    Jared Franzone
// File:      CoreData.swift
// Version:   1.0
// Purpose:   Hackillinois
// History:
//            1.0 initial version

import UIKit
import Foundation
import CoreData

class CoreData {
    
    
    // Managed Object Context
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    // MARK: Task core data Methods
    
    // MARK: Add Task
    func addDataPoint(duration: Int32, date: NSDate) {
        
        // create the task
        let dpToAdd = NSEntityDescription.insertNewObjectForEntityForName("Posture", inManagedObjectContext: managedObjectContext) as! Posture
        
        // set its values
        dpToAdd.duration = NSNumber(int: duration)
        dpToAdd.date = date
        
        // save it
        do {
            try managedObjectContext.save()
        } catch {
            fatalError("Failure to save task: \(dpToAdd) - error: \(error)")
        }
    } // end saveTask method
    
    
    
    
    
    // MARK: Update Task
    func updateDataPoint(duration: Int32, date: NSDate) {
        
        let temp = getAllDataPoints()
        
        if temp.count != 0 {
            let tempDP = temp[temp.count - 1]
            tempDP.setValue(NSNumber(int: duration), forKey: "duration")
            tempDP.setValue(date, forKey: "date")
        }
        
        // save the new status
        do {
            try managedObjectContext.save()
        } catch let updateError as NSError {
            print("Failure to update task:  - error: \(updateError.localizedDescription)")
        }
    } // end updateTask method
    
    
    
    
    
    
    // MARK: Delete a Task
    func deleteDataPoint(dataPointToDelete: Posture) {
        // delete
        managedObjectContext.deleteObject(dataPointToDelete)
        
        do {
            // save
            try managedObjectContext.save()
            
        } catch let deleteError as NSError {
            print("Failure to delete task: \(dataPointToDelete) - error: \(deleteError.localizedDescription)")
        }
    } // end deleteTask method
    
    
    
    
    
    
    
    // MARK: Get All Tasks
    func getAllDataPoints() -> [Posture] {
        
        // create fetch request and temp array
        let dpFetch = NSFetchRequest(entityName: "Posture")
        let fetchedTasks: [Posture]
        
        // fetch
        do {
            fetchedTasks = try managedObjectContext.executeFetchRequest(dpFetch) as! [Posture]
        } catch {
            fatalError("Failure to fetch tasks - error: \(error)")
        }
        
        // return fetched tasks
        return fetchedTasks
    } // end getAllTasks method
    
    
    
    
    // MARK: Print all CD to terminal
    func printAllCD() {
        let temp = getAllDataPoints()
        
        print("-----------------------------")
        for dp in temp {
            if let dur = dp.duration, date = dp.date {
                print("Duration: ", dur)
                print("Date: ", date)
            }
        }
        print("-----------------------------")
    }
    
    
    
    
    // MARK: Delete all Tasks
    func deleteAllTasks() {
        
        do { // Delete Task
            
            // get all tasks in core data
            let dataPoints = self.getAllDataPoints()
            
            // delete each task
            for dp in dataPoints {
                managedObjectContext.deleteObject(dp)
            }
            
            // save
            try managedObjectContext.save()
            
        } catch let deleteError as NSError { // catch any errors
            print("retrieveItemsSortedByDate error: \(deleteError.localizedDescription)")
        }
    }
    
} // end class



