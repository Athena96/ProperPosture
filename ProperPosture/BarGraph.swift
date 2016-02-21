//
//  BarGraph.swift
//  ProperPosture
//
//  Created by Jared Franzone on 2/21/16.
//  Copyright © 2016 Jared Franzone. All rights reserved.
//

import UIKit
import Foundation

class BarGraph: NSObject {
    
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

            
            // Make the hour label
            let lblX = bar!.frame.midX
            let lblY = bar!.frame.minY - 13
            hourLabel = UILabel(frame: CGRectMake(lblX, lblY, CGFloat(39), CGFloat(29)))
            hourLabel!.center = CGPointMake(lblX, lblY)
            hourLabel!.textAlignment = NSTextAlignment.Center
            hourLabel!.textColor = UIColor.whiteColor()
            hourLabel!.font = UIFont(name: "HelveticaNeue", size: CGFloat(20))
            hourLabel!.text = String(hours)
        }
        
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
    
    // Fixed Size Array
    var arrayOfDataPoints = [Bar]()
    
    func add(dp: Posture)
    {
        
        let inval = Double(dp.duration!)
        let perc: Double = inval / 57600.0
        let newH = (301 * perc)
        let newHCG = (newH <= 1) ? 3 : Int(newH)
        
        let day = NSCalendar.currentCalendar().components(NSCalendarUnit.Weekday, fromDate: dp.date!).weekday
        
        var bar: Bar?
        
        switch day {
            
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
        
        arrayOfDataPoints.append(bar!)
    }
    
    func drawGraph(vc: UIViewController)
    {
        if (arrayOfDataPoints.count <= 7)
        {
            
            for bar in arrayOfDataPoints
            {
                bar.draw(vc)
            }
            
        }
        else
        {
            print("error")
        }
    }
    
    // Reset the Graph
    func resetGraph()
    {
        for bar in arrayOfDataPoints
        {
            bar.remove()
        }
    }
    
    
    func demo(vc: UIViewController) {
        let b1 = Bar(x: 20, hours: 11, p: 0.9)
        b1.draw(vc)
        
        let b2 = Bar(x: 73, hours: 10, p: 0.3)
        b2.draw(vc)
        
        let b3 = Bar(x: 133, hours: 22, p: 0.5)
        b3.draw(vc)
        
        let b4 = Bar(x: 187, hours: 12, p: 0.1)
        b4.draw(vc)
        
        let b5 = Bar(x: 242, hours: 4, p: 0.75)
        b5.draw(vc)
        
        let b6 = Bar(x: 298, hours: 7, p: 0.25)
        b6.draw(vc)
        
        let b7 = Bar(x: 353, hours: 9, p: 1.0)
        b7.draw(vc)
    }
    
} // end Graph Class
