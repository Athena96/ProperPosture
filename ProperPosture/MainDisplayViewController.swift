
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
    var arrayOfGraphBars: [(UIView,UILabel)] = []
    var elapsed:Int32 = 0

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
        
        clearGraph()
        // DRAW EACH DAY
        for day in arrOfCDDataPoints {
            print(day)
            draw(day)
        }
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
        
        if !temp.isEmpty {
            for day in temp { draw(day) }
        }
        
    }


    // MARK: App Delegate Mehtods
    
    func applicationWillEnterForeground() {
        print("applicationWillEnterForeground --- called")
        clearGraph()
    }
    
    func draw(aDay: Posture) {
        
        guard let dt = aDay.date, val = aDay.duration else {
            return
        }
        
        let inval = Double(val)
        let perc: Double = inval / 57600.0
        
        
        let today = NSCalendar.currentCalendar().components(NSCalendarUnit.Weekday, fromDate: dt).weekday
        
        switch today {
            
        case Constants.day.Sunday:
            draw(20, percent: perc, hours: Int(val.integerValue/60/60))
            
        case Constants.day.Monday:
            draw(73, percent: perc,  hours: Int(val.integerValue/60/60))
            
        case Constants.day.Tuesday:
            draw(133, percent: perc, hours: Int(val.integerValue/60/60))
            
        case Constants.day.Wednesday:
            draw(187, percent: perc, hours: Int(val.integerValue/60/60))
            
        case Constants.day.Thursday:
            draw(242, percent: perc, hours: Int(val.integerValue/60/60))
            
        case Constants.day.Friday:
            draw(298, percent: perc, hours: Int(val.integerValue/60/60))
            
        case Constants.day.Saturday:
            draw(353, percent: perc, hours: Int(val.integerValue/60/60))
            
        default:
            break
            
        }
    }
    
    func draw(x: Int, percent: Double, hours: Int) {
        
        // DRAW BAR GRAPH
        let color = getColor(percent)
        let newH = (301 * percent)
        let newHCG = (newH <= 1) ? 3 : Int(newH)
        let smallFrame = CGRect(x: x, y: 745 - newHCG - 65, width: 39, height: newHCG)
        let bar = UIView(frame: smallFrame)
        bar.backgroundColor = color
        self.view.addSubview(bar)
        
        // DRAW ACOMPANIGN HOUR LABEL
        let temp = makeLabel(hours, x: Int(bar.frame.midX), y: Int(bar.frame.minY - 13), width: 39, height: 25)
        
        // ADD THIS TUPLE TO ARRAY SO I CAN DELETE LATER
        let tupleToSave = (bar, temp)
        arrayOfGraphBars.append(tupleToSave) // this is so i can delete them all later on
    }
    
    func makeLabel(hours: Int, x: Int, y: Int, width: Int, height: Int) -> UILabel{
        let cgx = CGFloat(x)
        let cgy = CGFloat(y)
        let label = UILabel(frame: CGRectMake(cgx, cgy, CGFloat(width), CGFloat(height)))
        label.center = CGPointMake(cgx, cgy)
        label.textAlignment = NSTextAlignment.Center
        label.textColor = UIColor.whiteColor()
        label.font = UIFont(name: "HelveticaNeue", size: CGFloat(20))
        label.text = String(hours)
        
        self.view.addSubview(label)
        
        return label
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
    
    func getColor(p: Double) -> UIColor {
        if (p > 0.847 && p <= 1.0)           {  return Constants.color.g1}
        else if (p > 0.684 && p <= 0.847)    {  return Constants.color.g2}
        else if (p > 0.5348 && p <= 0.684)   {  return Constants.color.g3}
        else if (p > 0.3754 && p <= 0.5348)  {  return Constants.color.g4}
        else if (p > 0.25581 && p <= 0.3754) {  return Constants.color.g5}
        else if (p > 0.1395 && p <= 0.25581) {  return Constants.color.g6}
        else {return Constants.color.g7}
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
        clearGraph()
    }
    
    func clearGraph() {
        for bar in arrayOfGraphBars {
            bar.0.removeFromSuperview()
            bar.1.removeFromSuperview()
        }
    }
    
    
    // TEST
    @IBAction func testDraw(sender: UIBarButtonItem) {
        
        draw(20, percent: 0.9, hours: 11)
        draw(73, percent: 0.3, hours: 10)
        draw(133, percent: 0.5, hours: 22)
        draw(187, percent: 0.1, hours: 12)
        draw(242, percent: 0.75, hours:4)
        draw(298, percent: 0.25, hours: 7)
        draw(353, percent: 1.0, hours: 9)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
