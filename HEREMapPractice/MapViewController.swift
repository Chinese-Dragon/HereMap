//
//  ViewController.swift
//  HEREMapPractice
//
//  Created by Mark on 4/10/18.
//  Copyright © 2018 hungryfool. All rights reserved.
//

import UIKit
import NMAKit

class MapViewController: UIViewController {
	
	var mapView: NMAMapView = {
		let map = NMAMapView(frame: CGRect.zero)
		return map
	}()
	
	let locationManger: CLLocationManager = CLLocationManager()
	
	let navButton: UIButton = {
		let btn = UIButton()
		btn.setTitle("NAV", for: .normal)
		btn.setTitleColor(UIColor.black, for: .normal)
		btn.backgroundColor = UIColor.white
		return btn
	}()
	
	var currentCoordinate: CLLocationCoordinate2D?
	let router: NMACoreRouter = NMACoreRouter()
	var currentRoute: NMARoute?
	var currentMapRoute: NMAMapRoute?
	let navManager: NMANavigationManager = NMANavigationManager.sharedInstance()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setUpViews()
		setUpLocationManager()
		navManager.delegate = self
	}
	
	private func setUpViews() {
		self.view.addSubview(mapView)
		self.mapView.addSubview(navButton)
		
		mapView.translatesAutoresizingMaskIntoConstraints = false
		mapView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
		mapView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
		mapView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
		mapView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
		
		navButton.translatesAutoresizingMaskIntoConstraints = false
		navButton.leftAnchor.constraint(equalTo: mapView.leftAnchor, constant: 50).isActive = true
		navButton.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 20).isActive = true
		navButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
		
		navButton.addTarget(self, action: #selector(navigate), for: .touchUpInside)
	}
	
	private func setUpLocationManager() {
		locationManger.requestAlwaysAuthorization()
		locationManger.requestWhenInUseAuthorization()
		locationManger.delegate = self
		locationManger.desiredAccuracy = kCLLocationAccuracyBestForNavigation
		locationManger.startUpdatingLocation()
	}
	
	func zoomToCoordinate(coordinate: CLLocationCoordinate2D) {
		let coordinates = NMAGeoCoordinates(latitude: coordinate.latitude, longitude: coordinate.longitude)
		mapView.set(geoCenter: coordinates, zoomLevel: 13, animation: .rocket)
	}
	
	@objc private func navigate() {
		// create stops
		guard let currentCoordinates = currentCoordinate?.toNMAGeoCoordinates() else {
			print("Current Location Not Found")
			return
		}
		
		let gfl = NMAGeoCoordinates(latitude: 37.408821, longitude: -122.146183)
		let stops = [currentCoordinates, gfl]
		
		// create routing Mode
		let routingMode: NMARoutingMode = NMARoutingMode(routingType: .fastest,
														 transportMode: .car,
														 routingOptions: [])
		
		// calculate route...
		router.calculateRoute(withStops: stops, routingMode: routingMode) { (result, error) in
			if let prevMapRoute = self.currentMapRoute {
				print("Removed previous Route")
				self.mapView.remove(mapObject: prevMapRoute)
			}
			
			guard error == NMARoutingError.none else {
				print(error)
				print(error.rawValue)
				return
			}
			
			guard let route = result?.routes?.last, let mapRoute = NMAMapRoute(route) else {
				print("No Available Routes Found")
				return
			}
			
			guard let boundingBox = route.boundingBox else {
				print("Unable to generate the bounding box for the current route")
				return
			}
			
			self.currentRoute = route
			self.currentMapRoute = mapRoute
			
			// show route on Map
			self.mapView.add(mapObject: mapRoute)
			
			// In order to see the entire route, we orientate the
			// map view
			// accordingly
			self.mapView.set(boundingBox: boundingBox, animation: .bow)
			
			// show all the menuvers
			if let maneuvers = self.currentRoute?.maneuvers {
				maneuvers.forEach {
					let maneuver = $0
					NMAManeuverAction
					print(maneuver.action.rawValue)
				}
			}
			
			// ready to start navigation
			// self.startNavigation()
		}
	}
	
	private func startNavigation() {
		// Simulation navigation by init the PositionSource with route and set movement speed
		let source = NMARoutePositionSource(route: currentRoute!)
		source.movementSpeed = 60
		NMAPositioningManager.sharedInstance().dataSource = source
		
		mapView.positionIndicator.isVisible = true
		navManager.map = self.mapView
		navManager.mapTrackingEnabled = true
		navManager.mapTrackingAutoZoomEnabled = true
		navManager.mapTrackingOrientation = .dynamic
		
		navManager.startTurnByTurnNavigation(currentRoute!)
	}
}

extension MapViewController: CLLocationManagerDelegate {
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		if let crtLocation = locations.last {
			print(crtLocation.coordinate)
			currentCoordinate = crtLocation.coordinate
			zoomToCoordinate(coordinate: crtLocation.coordinate)
			locationManger.stopUpdatingLocation()
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print(error)
	}
}

extension MapViewController: NMANavigationManagerDelegate {

}

extension CLLocationCoordinate2D {
	func toNMAGeoCoordinates() -> NMAGeoCoordinates {
		return NMAGeoCoordinates(latitude: self.latitude, longitude: self.longitude)
	}
}
