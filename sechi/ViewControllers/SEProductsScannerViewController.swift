/**
 *  Protocol used by SEProductsScannerViewController to inform it's delegate about code that was read or canceling reading process.
 */
protocol SEProductsScannerViewControllerDelegate {

	/**
	 *  Method called after reading a bar code
	 *
	 *  @param productsScannerViewController SEProductsScannerViewController that read the code
	 *  @param string                        string with decoded text of the barcode
	 */
	func productsScannerViewController(productsScannerViewController: SEProductsScannerViewController, didReadString string: String);

	/**
	 *  Method called if SEProducstsScannerViewController want to be dismissed
	 *
	 *  @param productsScannerViewController SEProductsScannerViewController object that want's to be dismissed.
	 */
	func productsScannerViewControllerDidCancelReading(productsScannerViewController: SEProductsScannerViewController);

}

/**
 *  View controller used for displaying a code scanner used in SEProductsListViewController
 */
class SEProductsScannerViewController: SEViewController, AVCaptureMetadataOutputObjectsDelegate

	/**
	 *  Delegate of the view controller
	 */
	weak var SEProductsScannerViewControllerDelegate delegate

	/**
	 *  View with preview of the camera
	 */
	@IBOutlet var previewView: UIView

	/**
	 *  Current status of the scanner
	 */
	@IBOutlet var statusLabel: UILabel

	/**
	 *  BOOL indicating if scanner is currently trying to find, read and decode value.
	 */
	var isReading: Bool!

	/**
	 *  Capture session used for video capture
	 */
	var captureSession: AVCaptureSession?

	/**
	 *  Video preview layer used for displaying current content seen by the camera
	 */
	var videoPreviewLayer: AVCaptureVideoPreviewLayer

	/**
	 *  Tap gesture recognizer used for informing delegate that the scanner wants to be dismissed.
	 */
	var tapGestureRecognizer: UITapGestureRecognizer!

	/**
	 *  Setup default property values and tap gesture recognizer.
	 */
	override func viewDidLoad()	{
	    super.viewDidLoad()
	    prefersStatusBarHidden()
	    
	    if self.respondsToSelector("setNeedsStatusBarAppearanceUpdate") {
	        self.setNeedsStatusBarAppearanceUpdate()
	    }

	    self.isReading = false
	    self.captureSession = nil
	    
	    self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "gestureRecognizerDidRecognize:")
	    self.previewView.addGestureRecognizer(self.tapGestureRecognizer)
	    
	    startReading()
	}

	func prefersStatusBarHidden() -> Bool {
	    return true
	}

	func childViewControllerForStatusBarHidden() -> UIViewController? {
	    return nil
	}

	/**
	 *  Stops reading and inform delegate that scanner wants to be dismissed.
	 *
	 *  @param gestureRecognizer gesture recognizer object that called the message
	 */
	func gestureRecognizerDidRecognize(gestureRecognizer: UIGestureRecognizer) {
	    stopReading()
	    self.delegate.productsScannerViewControllerDidCancelReading(self)
	}

	/**
	 *  Setup AVCaptureSession and start reading the codes from the camera stream.
	 *
	 *  @return YES if scanner did setup correctly and is waiting for code to show in camera. NO otherwise.
	 */
	func startReading() -> Bool {
	    var error: NSError?
	    
	    var captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
	    
	    var input = AVCaptureDeviceInput(device: captureDevice, error: &error)
	    
	    if !input {
	        NSLog("%@", error.localizedDescription)
	        return false
	    }
	    
	    self.captureSession = AVCaptureSession()
	    self.captureSession.addInput(input)
	    
	    var captureMetadataOutput = AVCaptureMetadataOutput()
	    self.captureSession.addOutput(captureMetadataOutput)
	    
	    var dispatchQueue = dispatch_queue_create("myQueue", nil)
	    captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatchQueue)
	    captureMetadataOutput.setMetadataObjectTypes([AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code])
	    
	    self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
	    self.videoPreviewLayer.setVideoGravity(AVLayerVideoGravityResizeAspectFill)
	    self.videoPreviewLayer.setFrame(self.previewView.layer.bounds)
	    self.previewView.layer.addSublayer(self.videoPreviewLayer)
	    
	    self.captureSession.startRunning()

	    self.previewView.bringSubviewToFront(self.statusLabel)
	    
	    return true
	}

	/**
	 *  Stops capture and reading the codes.
	 */
	func stopReading() {
	    self.captureSession.stopRunning()
	    self.captureSession = nil
	    
	    self.videoPreviewLayer.removeFromSuperlayer()
	}


	/**
	 *  Method called by AVCaptureMetadataOutput objects, when metadata object is found.
	 * 
	 *  This method informs
	 *
	 *  @param captureOutput   captureOutput that found metadata object
	 *  @param metadataObjects metadataObjects found
	 *  @param connection      connection of capture input and capture output
	 */
	func captureOutput(captureOutput: AVCaptureOutput, didOutputMetadataObjects metadataObjects: Array, fromConnection connection: AVCaptureConnection) {
	    if metadataObjects != nil && [metadataObjects count] > 0 {
	        
	        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
	        
	        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeCode39Code] || [[metadataObj type] isEqualToString:AVMetadataObjectTypeCode39Mod43Code]) {
	            
	            [self.statusLabel performSelectorOnMainThread:@selector(setText:) withObject:[metadataObj stringValue] waitUntilDone:NO];

	            self.performSelectorOnMainThread:@selector(stopReading) withObject:nil waitUntilDone:NO];
	            
	            self.performSelector("delegateReadedCode:", withObject: metadataObj.stringValue())
	            
	            self.isReading = false

	        }
	    }
	}


	/**
	 *  Inform the delegate that the metadata object was read
	 *
	 *  @param readedCode decoded metadata message
	 */
	func delegateReadedCode(readedCode: String) {
	    self.delegate.productsScannerViewController(self, didReadString: readedCode)
	}

}
