//
//  MathController.swift
//  JustRun
//
//  Created by Ju on 2017/4/9.
//  Copyright © 2017年 Ju. All rights reserved.
//

import UIKit
import MapKit

class MathController: NSObject {
    
    // MARK: - Public
    
    static func colorSegmentsForLocations(locations: [Location]) -> [MultiColorPolylineSegment] {
        var speeds = [Double]()
        var slowestSpeed = Double.greatestFiniteMagnitude
        var fastestSpeed = 0.0
        
        if locations.count >= 2 {
            for i in 1..<locations.count {
                let firstLoc: Location = locations[i-1]
                let secondLoc: Location = locations[i]
                
                let firstLocCL = CLLocation(latitude: firstLoc.latitude, longitude: firstLoc.longitude)
                let secondLocCL = CLLocation(latitude: secondLoc.latitude, longitude: secondLoc.longitude)
                
                let distance = secondLocCL.distance(from: firstLocCL)
                let time = secondLocCL.timestamp.timeIntervalSince(firstLocCL.timestamp)
                let speed = distance/time
                
                slowestSpeed = speed < slowestSpeed ? speed : slowestSpeed
                fastestSpeed = speed > fastestSpeed ? speed : fastestSpeed
                
                speeds.append(speed)
            }
        }
        
        let meanSpeed = (slowestSpeed + fastestSpeed) / 2
        
        // RGB for red
        let r_red = 1.0
        let r_green = 20/255.0
        let r_blue = 44/255.0
        
        // RGB for yellow
        let y_red = 1.0
        let y_green = 215/255.0
        let y_blue = 0.0

        // RGB for green
        let g_red = 0.0
        let g_green = 146/255.0
        let g_blue = 78/255.0
        
        var colorSegments = [MultiColorPolylineSegment]()
        
        if locations.count >= 2 {
            for i in 1..<locations.count {
                let firstLoc = locations[i-1]
                let secondLoc = locations[i]
                
                let cords1 = CLLocationCoordinate2DMake(firstLoc.latitude, firstLoc.longitude)
                let cords2 = CLLocationCoordinate2DMake(secondLoc.latitude, secondLoc.longitude)
                
                let speed = speeds[i-1]
                var color = UIColor.black
                
                // Between red and yellow
                if speed < meanSpeed {
                    let ratio = (speed - slowestSpeed)/(meanSpeed - slowestSpeed)
                    let red = r_red + ratio * (y_red - r_red)
                    let green = r_green + ratio * (y_green - r_green)
                    let blue = r_blue + ratio * (y_blue - r_blue)
                    color = UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1.0)
                } else { // between yellow and green
                    let ratio = (speed - meanSpeed) / (fastestSpeed - meanSpeed)
                    let red = y_red + ratio * (g_red - y_red)
                    let green = y_green + ratio * (g_green - y_green)
                    let blue = y_blue + ratio * (g_blue - y_blue)
                    color = UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1.0)
                }
                
                let segment: MultiColorPolylineSegment = MultiColorPolylineSegment(coordinates: [cords1, cords2], count: 2)
                segment.color = color
                
                colorSegments.append(segment)
            }
        }
        
        return colorSegments
    }
    
    static func stringifyDistance(meters: Float) -> String {
        let unitDivider = isMetric ? metrisInKM : metriesInMile
        let unitName = isMetric ? "km" : "mi"
        return "\(String(format: "%.2f", meters/unitDivider)) \(unitName)"
    }
    
    static func stringifySecondCount(seconds: Int, usingLongFormat longFormat: Bool) -> String {
        var remainingSeconds = seconds
        let hours = remainingSeconds / 3600
        remainingSeconds = remainingSeconds - hours * 3600
        let minutes = remainingSeconds / 60
        remainingSeconds = remainingSeconds - minutes * 60
        
        if longFormat {
            if hours > 0 {
                return "\(hours) hr \(minutes) min \(remainingSeconds) sec"
            } else if minutes > 0 {
                return "\(minutes) min \(remainingSeconds) sec"
            } else {
                return "\(remainingSeconds) sec"
            }
        } else {
            if hours > 0 {
                return "\(String(format: "%02i", hours)) hr \(String(format: "%02i", minutes)) min \(String(format: "%02i", remainingSeconds)) sec"
            } else if minutes > 0 {
                return "\(String(format: "%02i", minutes)) min \(String(format: "%02i", remainingSeconds)) sec"
            } else {
                return "00:\(String(format: "%02i", remainingSeconds)) sec"
            }
        }
    }
    
    static func stringifyAvgPaceFromDist(meters: Float, overTime seconds: Int) -> String {
        if meters == 0 || seconds == 0 {
            return "0"
        }
        
        let avgPaceSecMeters = Float(seconds) / meters
        var unitMultiplier: Float
        var unitName: String
        
        if isMetric {
            unitName = "min/km"
            unitMultiplier = metrisInKM
        } else {
            unitName = "min/mi"
            unitMultiplier = metriesInMile
        }
        
        let paceMin = Int(((avgPaceSecMeters * unitMultiplier) / 60));
        let paceSec = Int(avgPaceSecMeters * unitMultiplier) - (paceMin*60);
        
        return "\(paceMin):\(String(format: "%02i", paceSec)) \(unitName)"
    }

    // MARK: - Private
    
    static private let isMetric = true
    static private let metrisInKM: Float = 1000
    static private let metriesInMile: Float = 1609.344
}

