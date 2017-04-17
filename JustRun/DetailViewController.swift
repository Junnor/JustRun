//
//  DetailViewController.swift
//  JustRun
//
//  Created by Ju on 2017/4/9.
//  Copyright © 2017年 Ju. All rights reserved.
//

import UIKit
import MapKit

class DetailViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.delegate = self
        }
    }

    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    
    private func mapRegion() -> MKCoordinateRegion {
        var region = MKCoordinateRegion()
        let firstLoc = run!.locations?.firstObject as! Location
        var minLat = firstLoc.latitude
        var minLng = firstLoc.longitude
        var maxLat = firstLoc.latitude
        var maxLng = firstLoc.longitude

        let locations = self.run?.locations?.array as! [Location]
        for location in locations {
            if location.latitude < minLat {
                minLat = location.latitude
            }
            if location.longitude < minLng {
                minLng = location.longitude
            }
            if location.latitude > maxLat {
                maxLat = location.latitude
            }
            if location.longitude > maxLng {
                maxLng = location.longitude
            }
        }
        
        region.center.latitude = (minLat + maxLat) / 2
        region.center.longitude = (minLng + maxLng) / 2
        region.span.latitudeDelta = (maxLat - minLat) * 1.1
        region.span.longitudeDelta = (maxLng - minLng) * 1.1

        return region
    }
    

    // MARK: - Map view delegate
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay.isKind(of: MultiColorPolylineSegment.self) {
            let polyline = overlay as! MultiColorPolylineSegment
            let aRender = MKPolylineRenderer(polyline: polyline)
            aRender.strokeColor = polyline.color
            aRender.lineWidth = 3
            return aRender
        }
        return MKOverlayRenderer()
    }
    
    private func polyline() -> MKPolyline {
        let locations = self.run!.locations!.array as! [Location]
        var cords = [CLLocationCoordinate2D]()

        for i in 0..<locations.count {
            let location = locations[i]
            cords.append(CLLocationCoordinate2DMake(location.latitude, location.longitude))
        }
        let polyLine = MKPolyline(coordinates: cords, count: locations.count)

        return polyLine
    }
    
    private func loadMap() {
        if let count = self.run?.locations?.count, count > 0 {
            mapView?.isHidden = false
            mapView?.region = mapRegion()
            
            let colorSegments = MathController.colorSegmentsForLocations(locations: self.run?.locations?.array as! [Location])
            mapView?.addOverlays(colorSegments)
        }
    }
    
    private func configureView() {
        distanceLabel?.text = "\(MathController.stringifyDistance(meters: (run?.distance)!))"
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        dateLabel?.text = "\(formatter.string(from: (run?.timestamp)! as Date))"
        timeLabel?.text = "Time: \(MathController.stringifySecondCount(seconds: Int((run?.duration)!), usingLongFormat: true))"
        paceLabel?.text = "Pace: \(MathController.stringifyAvgPaceFromDist(meters: (run?.distance)!, overTime: Int((run?.duration)!)))"
        
        loadMap()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }

    var run: Run? {
        didSet {
            configureView()
        }
    }

}

