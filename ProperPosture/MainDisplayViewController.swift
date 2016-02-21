
// Author:    Jared Franzone
// File:      MainDisplayViewController.swift
// Version:   1.0
// Purpose:   Hackillinois
// History:
//            1.0 initial version

import UIKit
import CoreData

let mySpecialNotificationKey = "com.jaredFranzone.wait"
let newNotification = "com.jaredFranzone.disconnected"

class MainDisplayViewController: UIViewController {
    
    @IBOutlet weak var bar: UINavigationItem!
    @IBOutlet weak var introLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var goodLabel: UILabel!
    
    // Core Data
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var arrOfCDDataPoints = [Posture]()
    let coreData = CoreData()
    
    
    // this is so i can delete them all later on
    var elapsed:Int32 = 0
    
    var graph = BarGraph()

    var date = NSDate()
    var deleted: Bool = false
    
    var posture = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        introLabel.hidden = true
        goodLabel.hidden = true
        timeLabel.text = "connecting..."
    
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateNotificationSentLabel", name: mySpecialNotificationKey, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didDisconnect", name: newNotification, object: nil)

    
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "applicationWillEnterForeground", name: UIApplicationWillEnterForegroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: "applicationWillTerminate", name: UIApplicationWillTerminateNotification, object: nil)
        notificationCenter.addObserver(self, selector: "applicationDidEnterBackground", name: UIApplicationDidEnterBackgroundNotification, object: nil)

        DiscoverInstance
    }
  
    func didDisconnect() {
        if let msad = message {
            timeLabel.font = UIFont(name: "HelveticaNeue-Thin", size: CGFloat(45))
            timeLabel.textColor = UIColor(red: 0.9490, green: 0.43529, blue: 0.39215, alpha: 1.9)
            timeLabel.textAlignment = NSTextAlignment.Center
            timeLabel.text = msad
        }
        
    }
    
    func updateNotificationSentLabel() {
        show()
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
    
    func show() {
        
        
        // Display Data and Temporarily Store the data points for when we close the app
        if let bleService = DiscoverInstance.bluetoothService {
            introLabel.hidden = false
            goodLabel.hidden = false
            let data = bleService.readPosture()
            if (data < 0) {
                timeLabel.font = UIFont(name: "HelveticaNeue-Thin", size: CGFloat(45))
                timeLabel.textColor = UIColor(red: 0.9490, green: 0.43529, blue: 0.39215, alpha: 1.9)
                timeLabel.textAlignment = NSTextAlignment.Center
                timeLabel.text = "sit up please :-)"
            } else {
                timeLabel.font = UIFont(name: "HelveticaNeue-Thin", size: CGFloat(65))
                timeLabel.textColor = UIColor.whiteColor()
                let formatted = formatAlgorithm(data)
                timeLabel.text = formatted
                
                elapsed = data
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
        
        /*
        if !temp.isEmpty {
            for day in temp { draw(day) }
        }
*/
        
    }


    // MARK: App Delegate Mehtods
    
    func applicationWillEnterForeground() {
        print("applicationWillEnterForeground --- called")
        graph.resetGraph()
    }
    
    // Format 01:01:01 Algorithm
    func formatAlgorithm(seconds: Int32) ->String {
        
        let (h, m, s) = getHourMinSec(seconds)
        var hour = ""; var min = ""; var sec = ""
        if h < 10 {
            hour = "0" + String(h)
        } else {
            hour = String(h)
        }
        
        if m < 10 {
            min = "0" + String(m)
        } else {
            min = String(m)
        }
        
        if s < 10 {
            sec = "0" + String(s)
        } else {
            sec = String(s)
        }
    
        let returnVal = hour + ":" + min + ":" + sec
        
        return returnVal
    }
    
    func getHourMinSec(sec: Int32) ->(Int32, Int32, Int32) {
        return (sec / Int32(3600), (sec % 3600) / 60, (sec % 3600) % 60)
    }
    
    func applicationDidEnterBackground() {
        print("applicationDidEnterBackground --- called")
        endSaveORDelete()
    }
    
    func applicationWillTerminate() {
        print("applicationDidEnterBackground --- called")
        endSaveORDelete()
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
    
    @IBAction func deleteAllTapped(sender: UIBarButtonItem) {
        coreData.deleteAllTasks()
        coreData.printAllCD()
        graph.resetGraph()
    }
    
    // TEST
    @IBAction func testDraw(sender: UIBarButtonItem) {
        graph.demo(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
