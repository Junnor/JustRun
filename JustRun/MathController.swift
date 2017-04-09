//
//  MathController.swift
//  JustRun
//
//  Created by Ju on 2017/4/9.
//  Copyright © 2017年 Ju. All rights reserved.
//

import UIKit

class MathController: NSObject {
    
    // MARK: - Public
    
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

