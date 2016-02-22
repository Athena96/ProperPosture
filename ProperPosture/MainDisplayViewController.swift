
// Author:    Jared Franzone
// File:      MainDisplayViewController.swift
// Version:   1.0
// Purpose:   Hackillinois
// History:
//            1.0 initial version

import UIKit
import CoreData

// Global Values
let mySpecialNotificationKey = "com.jaredFranzone.wait"
let newNotification = "com.jaredFranzone.disconnected"

class MainDisplayViewController: UIViewController {
    
    // MARK: IBOutlets
    @IBOutlet weak var bar: UINavigationItem!
    @IBOutlet weak var introLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var goodLabel: UILabel!
    
    // MARK: Member Variables
    
    // Core Data
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var arrOfCDDataPoints = [Posture]()
    let coreData = CoreData()
    
    // Graph
    var graph = BarGraph()
    
    // Holding For saving Data
    var elapsed:Int32 = 0
    var date = NSDate()
    
    // Logic
    var deleted: Bool = false
    
    
    // MARK: - ViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        introLabel.hidden = true
        goodLabel.hidden = true
        timeLabel.text = "connecting..."
        
        // Get notificcation updating value and disconnecting
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateNotificationSentLabel", name: mySpecialNotificationKey, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didDisconnect", name: newNotification, object: nil)
        
        //
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "applicationWillTerminate", name: UIApplicationWillTerminateNotification, object: nil)
        notificationCenter.addObserver(self, selector: "applicationDidEnterBackground", name: UIApplicationDidEnterBackgroundNotification, object: nil)
        
        // Start Search For Bluetooth
        DiscoverInstance
    }
    
    override func viewDidAppear(animated: Bool) {
        print("viewDidAppear --- called")
        introLabel.hidden = true
        goodLabel.hidden = true
        timeLabel.text = "connecting..."
        
        // DELETE EVERY MONDAY
        arrOfCDDataPoints = coreData.getAllDataPoints()
        // if need to delete... delete
        let weekday = NSCalendar.currentCalendar().components(NSCalendarUnit.Weekday, fromDate: NSDate()).weekday
        if weekday == 2 && !arrOfCDDataPoints.isEmpty && deleted == false {
            print("delete all")
            coreData.deleteAllTasks()
            deleted = true
        } else if weekday == 3 {
            deleted = false // so we can delete again on monday
        }
        
        
        graph.resetGraph()
        for dp in arrOfCDDataPoints
        {
            graph.add(dp)
        }
        graph.drawGraph(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: App Delegate Mehtods
    
    func applicationWillEnterForeground() {
        print("applicationWillEnterForeground --- called")
        graph.resetGraph()
    }
    
    func applicationDidEnterBackground() {
        print("applicationDidEnterBackground --- called")
        endSaveORDelete()
    }
    
    func applicationWillTerminate() {
        print("applicationDidEnterBackground --- called")
        endSaveORDelete()
    }
    
    // MARK: Bluetooth
    
    func didDisconnect() {
        if let msad = message {
            timeLabel.font = UIFont(name: "HelveticaNeue-Thin", size: CGFloat(45))
            timeLabel.textColor = UIColor(red: 0.9490, green: 0.43529, blue: 0.39215, alpha: 1.9)
            timeLabel.textAlignment = NSTextAlignment.Center
            timeLabel.text = msad
        }
    }
    
    func updateNotificationSentLabel() {
        // Display Data and Temporarily Store the data points for when we close the app
        if let bleService = DiscoverInstance.bluetoothService {
            introLabel.hidden = false
            goodLabel.hidden = false
            let data = bleService.readPosture()
            if (data.0 == "BAD_DATA" && data.1 < 0) {
                timeLabel.font = UIFont(name: "HelveticaNeue-Thin", size: CGFloat(45))
                timeLabel.textColor = UIColor(red: 0.9490, green: 0.43529, blue: 0.39215, alpha: 1.9)
                timeLabel.textAlignment = NSTextAlignment.Center
                timeLabel.text = "sit up please :-)"
            } else {
                timeLabel.font = UIFont(name: "HelveticaNeue-Thin", size: CGFloat(65))
                timeLabel.textColor = UIColor.whiteColor()
                timeLabel.text = data.0
                
                elapsed = data.1
                date = NSDate()
            }
        }
        
        let temp = coreData.getAllDataPoints()
        let weekday = NSCalendar.currentCalendar().components(NSCalendarUnit.Weekday, fromDate: NSDate()).weekday
        
        if weekday == 2 && !temp.isEmpty == false && deleted == false {
            coreData.deleteAllTasks()
            deleted = true
        }
        graph.resetGraph()
        graph.drawGraph(self)
    }
    
    
    func endSaveORDelete() {
        let temp = coreData.getAllDataPoints()
        
        if temp.isEmpty {
            save()
        } else {
            
            // Get the date from the last item in CD and
            // see if it is today... if it is then we should update its place
            // in CD... not create a new entry
            let end = temp.count - 1
            let date = temp[end].date
            let calendar = NSCalendar.currentCalendar()
            let components = calendar.components([.Day , .Month , .Year], fromDate: date!)
            let day = components.day
            
            let today = NSDate()
            let myCal = NSCalendar.currentCalendar()
            let myComp = myCal.components([.Day , .Month , .Year], fromDate: today)
            let toDAY = myComp.day
            
            if(day == toDAY){ self.update() }
            else { self.save() }
        }
    }
    
    func save() {
        print("save called")
        print("elapsed: ", elapsed)
        coreData.addDataPoint(elapsed, date: date)
    }
    
    func update() {
        print("update called")
        print("elapsed: ", elapsed)
        coreData.updateDataPoint(elapsed, date: date)
    }
    
    
    
}
