
// Author:    Jared Franzone
// File:      BarGraph.swift
// Version:   1.0
// Purpose:   (Post) Hackillinois
// History:
//            1.0 initial version

import UIKit
import Foundation

class BarGraph: NSObject {
    
    // MARK: Hidden Class 
    
    class Bar: NSObject {
        
        // MARK: - Member Vars
        
        var hourLabel: UILabel?
        var bar: UIView?
        
        // MARK: - Constructor
        
        init(x:Int, hours: Int, p: Double) {
            
            // Make the Bar
            let h = Int(301 * p)
            let height = (h <= 1) ? 3 : h // so we dont have an empty graph
            let calculateedY = 745 - height - 65
            let smallFrame = CGRect(x: x, y: calculateedY, width: 39, height: height)
            
            var color:UIColor?
            if (p > 0.847 && p <= 1.0)           {  color = Constants.color.g1}
            else if (p > 0.684 && p <= 0.847)    {  color =  Constants.color.g2}
            else if (p > 0.5348 && p <= 0.684)   {  color =  Constants.color.g3}
            else if (p > 0.3754 && p <= 0.5348)  {  color =  Constants.color.g4}
            else if (p > 0.25581 && p <= 0.3754) {  color =  Constants.color.g5}
            else if (p > 0.1395 && p <= 0.25581) {  color =  Constants.color.g6}
            else {color =  Constants.color.g7}
            
            bar = UIView(frame: smallFrame)
            bar!.backgroundColor = color

            
            // Make the "hour" label
            let lblX = bar!.frame.midX
            let lblY = bar!.frame.minY - 13
            hourLabel = UILabel(frame: CGRectMake(lblX, lblY, CGFloat(39), CGFloat(29)))
            hourLabel!.center = CGPointMake(lblX, lblY)
            hourLabel!.textAlignment = NSTextAlignment.Center
            hourLabel!.textColor = UIColor.whiteColor()
            hourLabel!.font = UIFont(name: "HelveticaNeue", size: CGFloat(20))
            hourLabel!.text = String(hours)
        }
        
        
        // MARK: - Helper Functions
        
        func draw(vc: UIViewController) {
            if let hl = hourLabel {
                vc.view.addSubview(bar!)
                vc.view.addSubview(hl)
            }
        }
        
        func remove() {
            hourLabel?.removeFromSuperview()
            hourLabel?.removeFromSuperview()
        }
        
    } // end Bar class
    
    
    // MARK: - Bar Graph Class
    
    // Array of bars
    var arrayOfDataPoints = [Bar]()
    
    // Add bars to graph
    func add(dp: Posture) {
        
        // We only want 7 bars (7 days)
        if (arrayOfDataPoints.count > 7) {
            print("too big")
            return
        }
        
        // Calculate measurements for the bar we are
        let inval = Double(dp.duration!)
        let perc: Double = inval / 57600.0
        let dayToDraw = NSCalendar.currentCalendar().components(NSCalendarUnit.Weekday, fromDate: dp.date!).weekday
        
        var bar: Bar?
        
        // Switch statement do we draw the bar in the correct spot
        switch dayToDraw {
            
        case Constants.day.Sunday:
            bar = Bar(x: 20, hours: Int(inval/60/60), p: perc)
            
        case Constants.day.Monday:
            bar = Bar(x: 73, hours: Int(inval/60/60), p: perc)
            
            
        case Constants.day.Tuesday:
            bar = Bar(x: 133, hours: Int(inval/60/60), p: perc)
            
            
        case Constants.day.Wednesday:
            bar = Bar(x: 187, hours: Int(inval/60/60), p: perc)
            
            
        case Constants.day.Thursday:
            bar = Bar(x: 242, hours: Int(inval/60/60), p: perc)
            
            
        case Constants.day.Friday:
            bar = Bar(x: 298, hours: Int(inval/60/60), p: perc)
            
            
        case Constants.day.Saturday:
            bar = Bar(x: 353, hours: Int(inval/60/60), p: perc)
            
        default:
            break
            
        }
        
        if let barDP = bar {
            arrayOfDataPoints.append(barDP)
        } else { print("error in: add") }
    }
    
    // Draw the Graph you have made
    func drawGraph(vc: UIViewController) {
        for bar in arrayOfDataPoints {
            bar.draw(vc)
        }
    }
    
    // Reset the Graph
    func resetGraph() {
        for bar in arrayOfDataPoints {
            bar.remove()
        }
    }
    
} // end Graph Class
