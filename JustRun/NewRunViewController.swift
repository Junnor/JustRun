//
//  NewRunViewController.swift
//  JustRun
//
//  Created by Ju on 2017/4/9.
//  Copyright © 2017年 Ju. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class NewRunViewController: UIViewController, CLLocationManagerDelegate {

    // MARK: - For data persistence
    
    var managedObjectContext: NSManagedObjectContext?
    var run: Run?

    // MARK: - For location
    
    var seconds: Int = 0
    var distance: Float = 0
    var locations = [CLLocation]()
    var timer: Timer! = nil
    lazy var locationManager: CLLocationManager = {
        return CLLocationManager()
    }()
    
    // MARK: - Outlets
    
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    // MARK: - VC lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        hideStartButtonAndPropmt(false, reversOtherUI: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }
    
    private func saveRun() {
        let newRun: Run = NSEntityDescription.insertNewObject(forEntityName: "Run", into: managedObjectContext!) as! Run
        newRun.distance = distance
        newRun.duration = Int16(seconds)
        newRun.timestamp = NSDate()
        
        var locationArray = [Location]()
        for location in self.locations {
            let locationObject = NSEntityDescription.insertNewObject(forEntityName: "Location", into: managedObjectContext!) as! Location
            locationObject.timestamp = location.timestamp as NSDate
            locationObject.latitude = location.coordinate.latitude
            locationObject.longitude = location.coordinate.longitude
            locationArray.append(locationObject)
        }
        
        newRun.locations = NSOrderedSet(array: locationArray)
        self.run = newRun
        
        do {
            try managedObjectContext?.save()
        } catch {
            print("Save run data error: \(error)")
        }
    }
    
    // MARK: - Helper
    
    @objc private func eachSeconds() {
        seconds += 1
        timeLabel?.text = "Time: \(MathController.stringifySecondCount(seconds: seconds, usingLongFormat: false))"
        distanceLabel?.text = "Distance: \(MathController.stringifyDistance(meters: distance))"
        paceLabel?.text = "Pace: \(MathController.stringifyAvgPaceFromDist(meters: distance, overTime: seconds))"
    }
    
    private func startLocationUpdates() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .fitness
        
        locationManager.distanceFilter = 10
        if #available(iOS 8.0, *) {
            locationManager.requestAlwaysAuthorization()
        }
        locationManager.startUpdatingLocation()
    }
    
    private func hideStartButtonAndPropmt(_ hiden: Bool, reversOtherUI reverse : Bool) {
        startButton.isHidden = hiden
        promptLabel.isHidden = hiden
        
        distanceLabel.isHidden = reverse
        timeLabel.isHidden = reverse
        paceLabel.isHidden = reverse
        stopButton.isHidden = reverse
    }
    
    @IBAction func startPressed(_ sender: Any) {
        hideStartButtonAndPropmt(true, reversOtherUI: false)
        seconds = 0
        distance = 0
        locations.removeAll()
        let selector = #selector(self.eachSeconds)
        timer = Timer(timeInterval: 1.0,
                      target: self,
                      selector: selector,
                      userInfo: nil,
                      repeats: true)
        let runLoop = RunLoop.current
        runLoop.add(timer, forMode: .defaultRunLoopMode)
        
        startLocationUpdates()
    }
    
    private let detailSegueName = "RunDetails"
    
    @IBAction func stopPressed(_ sender: Any) {
        let alert = UIAlertController(title: "New Run Stuff", message: "", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        // TODO: Check whether trig reference circle
        let saceAction = UIAlertAction(title: "Save", style: .default, handler: { [weak self] action in
            self?.saveRun()
            self?.performSegue(withIdentifier: (self?.detailSegueName)!, sender: nil)
        })
        let discardAction = UIAlertAction(title: "Discard", style: .default, handler: { action in
            if let homeNavi = self.splitViewController?.viewControllers[0] as? UINavigationController {
                homeNavi.popToRootViewController(animated: true)
            }
        })
        alert.addAction(cancelAction)
        alert.addAction(saceAction)
        alert.addAction(discardAction)
        self.navigationController?.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier != nil {
            if let detailVC = segue.destination.contents as? DetailViewController {
                detailVC.run = run
            }
        }
        
    }
    
    // MARK: - Location Delegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for newLocation in locations {
            if newLocation.horizontalAccuracy < 20 {
                if self.locations.count > 0 {
                    distance = Float(newLocation.distance(from: self.locations.last!))
                }
                self.locations.append(newLocation)
            }
        }
    }

}

extension UIViewController {
    var contents: UIViewController {
        get {
            if let controller = self as? UINavigationController {
                return controller.visibleViewController ?? self
            } else {
                return self
            }
        }
    }
}
