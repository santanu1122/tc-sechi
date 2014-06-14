/**
 *  View controller used for displaying a map with marked job address and option to show directions to it.
 */
class SEJobMapViewController: SEViewController, MKMapViewDelegate, UITextViewDelegate {

	/**
	 *  SEJob object, view controller will show an address from it to display.
	 */
	var job: SEJob!

	/**
	 *  Text view with address of the job
	 */
	@IBOutlet var addressTextView: SETextView

	/**
	 *  Map view that will display pin on job address, and route to it if needed
	 */
	@IBOutlet var mapView: MKMapView

	/**
	 *  MKPointAnnotation object of the job address
	 */
	var jobAnnotation = MKPointAnnotation()

	/**
	 *  MKAnnotationView shown at jobAnnotation
	 */
	var jobAnnotationView = MKPinAnnotationView(annotation: self.jobAnnotation, reuseIdentifier: "nil")

	/**
	 *  Setup views properties
	 */
	func viewDidLoad() {
	    super.viewDidLoad()
	    self.addressTextView.delegate = self
	    self.addressTextView.text = self.job.jobAddressC
	    self.mapView.delegate = self
	}

	/**
	 *  Setup navigation bar visible, and it's buttons. Update map view with current address.
	 *
	 *  @param animated
	 */
	func viewWillAppear(animated: Bool) {
	    super.viewWillAppear(animated)
	    self.navigationController.setNavigationBarHidden(false, animated: animated)
	    self.setupNavigationBarBackButton()
	    self.updateMap()
	}

	#pragma mark - UITextViewDelegate
	/**
	 *  Hide keyboard on return when text view is a first responder
	 *
	 *  @param textView
	 *  @param range
	 *  @param text
	 *
	 *  @return BOOL should change the content of the text view
	 */
	func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
	    if text == "\n" {
	        textView.resignFirstResponder()
	        return false
	    }
	    return true
	}

	#pragma mark - Actions
	/**
	 *  Update map pin location when map button was pressed
	 *
	 *  @param sender object that called the method
	 */
	@IBAction func mapButtonTouchedUpInside(sender: UIButton) {
	    self.updateMap()
	}

	/**
	 *  Show or update the route to pin when directions button was pressed
	 *
	 *  @param sender object that called the method
	 */
	@IBAction func directionsButtonTouchedUpInside(sender: UIButton) {
	    self.updateMapCompletion {
	    	() -> () in
	        self.showDirections()
	    }
	}

	#pragma mark - Direction actions

	/**
	 *  Creates MKDirections request and displays directions on map if response is successfull.
	 */
	func showDirections() {

	    var jobPlacemark = MKPlacemark(coordinate: self.jobAnnotation.coordinate, addressDictionary: nil)
	    
	    var request = MKDirectionsRequest()
	    request.source = MKMapItem.mapItemForCurrentLocation()
	    request.destination = MKMapItem(placemark: jobPlacemark)
	    request.requestsAlternateRoutes = false
	    
	    var directions = MKDirections(request: request)
	    directions.calculateDirectionsWithCompletionHandler {
	    	(response: MKDirectionsResponse, error: NSError) -> () in
	        if error {
	            if let errorMessage = messageForCLError(error)? {
	                NSLog("WARNING: Error message for error %@ not found in CL errors list.", error!)
	                errorMessage = "Error occured: " + error!.localizedDescription
	            }
	            UIAlertView(title: "Error", message: errorMessage, delegate: nil, cancelButtonTitle: "OK", otherButtonTitles: nil).show()
	        }
	        else {
	            self.showDirections(response)
	        }
	    }
	}

	/**
	 *  Display routes overlays on map.
	 *
	 *  @param response MKDirectionsResponse object with routes to selected address
	 */
	func showDirections(response: MKDirectionsResponse) {
	    self.mapView.removeOverlays(self.mapView.overlays)
	    
	    for var route in response.routes {
	        self.mapView.addOverlay(route.polyline, level: .AboveRoads)
	    }
	}

	/**
	 *  Return MKOverlayRenderer for overlay to display
	 *
	 *  @param mapView map view where overlay will be displayed
	 *  @param overlay overlay for which renderer will be returned
	 *
	 *  @return MKOverlayRenderer object for overlay or nil
	 */
	func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer? {
	    if var route = overlay as? MKPolyline {
	        var routeRenderer = MKPolylineRenderer(polyline: route)
	        routeRenderer.strokeColor = UIColor.blueColor()
	        return routeRenderer
	    } else {
	    	return nil
	    }
	}

	#pragma mark - Map actions
	/**
	 *  Update location of pin on map to show current address.
	 */
	func updateMap() {
	    self.updateMapCompletion(nil)
	}

	/**
	 *  Update location of pin on map to show current address, with completition handler.
	 */
	func updateMapCompletion(completion: () -> ()?) {
	    var placeDictionary = Dictionary<String, String>()
	    var addressComponents = self.addressTextView.text.componentsSeparatedByString(",")
	    if addressComponents.count > 1 {
	        placeDictionary["Street"] = addressComponents[0]
	        placeDictionary["City"] = addressComponents[0]
	    } else {
	        placeDictionary["Street"] = self.addressTextView.text
	    }
	    
	    var geocoder = CLGeocoder()
	    geocoder.geocodeAddressDictionary(placeDictionary) {
	    	(placemarks: CLPlacemark[], error: NSError) -> () in
	    	if placemarks.count > 0 {
	    		var placemark = placemarks[0]
	    		var location = placemark.location
	            var coordinate = location.coordinate
	            self.jobAnnotation.setCoordinate(coordinate)
	            self.mapView.setCenterCoordinate(coordinate, animated: true)
	            if self.mapView.annotations.count == 0 {
	            	self.mapView.addAnnotation(self.jobAnnotation)
	            }
	            if completion {
	            	completion()
	            }
	        } else {
	        	var errorMessage = messageForCLError(error)
	        	if let errorMessage = messageForCLError(error)? {
	        		NSLog("WARNING: Error message for error %@ not found in CL errors list.", error!)
	        		errorMessage = "Error occured: " + error!.localizedDescription
	        	}
	        	UIAlertView(title: "Error", message: errorMessage, delegate: nil, cancelButtonTitle: "OK", otherButtonTitles: nil).show()
	        }
	    }
	}

	/**
	 *  Returns MKAnnotationView for annotation
	 *
	 *  @param mapView    map view where annotation will be displayed
	 *  @param annotation annotation for which view was requested
	 *
	 *  @return MKAnnotationView for annotation
	 */
	func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView {
	    return self.jobAnnotationView
	}

}
