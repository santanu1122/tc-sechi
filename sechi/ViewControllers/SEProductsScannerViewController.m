//
//  SEProductsScannerViewController.m
//  sechi
//
//  Created by karolszafranski on 09.05.2014.
//  Copyright (c) 2014 TopCoder Inc. All rights reserved.
//

#import "SEProductsScannerViewController.h"

@interface SEProductsScannerViewController()

/**
 *  View with preview of the camera
 */
@property (strong, nonatomic) IBOutlet UIView *previewView;

/**
 *  Current status of the scanner
 */
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;

/**
 *  BOOL indicating if scanner is currently trying to find, read and decode value.
 */
@property (nonatomic) BOOL isReading;

/**
 *  Capture session used for video capture
 */
@property (nonatomic, strong) AVCaptureSession *captureSession;

/**
 *  Video preview layer used for displaying current content seen by the camera
 */
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;

/**
 *  Tap gesture recognizer used for informing delegate that the scanner wants to be dismissed.
 */
@property (strong, nonatomic) UITapGestureRecognizer* tapGestureRecognizer;

@end

@implementation SEProductsScannerViewController

/**
 *  Setup default property values and tap gesture recognizer.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self prefersStatusBarHidden];
    
    if([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [self setNeedsStatusBarAppearanceUpdate];
    }

    _isReading = NO;
    _captureSession = nil;
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                        action:@selector(gestureRecognizerDidRecognize:)];
    [self.previewView addGestureRecognizer:self.tapGestureRecognizer];
    
    [self startReading];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return nil;
}

/**
 *  Stops reading and inform delegate that scanner wants to be dismissed.
 *
 *  @param gestureRecognizer gesture recognizer object that called the message
 */
- (void) gestureRecognizerDidRecognize: (UIGestureRecognizer*) gestureRecognizer {
    [self stopReading];
    [self.delegate productsScannerViewControllerDidCancelReading:self];
}

/**
 *  Setup AVCaptureSession and start reading the codes from the camera stream.
 *
 *  @return YES if scanner did setup correctly and is waiting for code to show in camera. NO otherwise.
 */
- (BOOL)startReading {
    NSError *error;
    
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if (!input) {
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }
    
    _captureSession = [[AVCaptureSession alloc] init];
    [_captureSession addInput:input];
    
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [_captureSession addOutput:captureMetadataOutput];
    
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code]];
    
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_videoPreviewLayer setFrame:_previewView.layer.bounds];
    [_previewView.layer addSublayer:_videoPreviewLayer];
    
    [_captureSession startRunning];

    [self.previewView bringSubviewToFront:self.statusLabel];
    
    return YES;
}

/**
 *  Stops capture and reading the codes.
 */
-(void)stopReading{
    [_captureSession stopRunning];
    _captureSession = nil;
    
    [_videoPreviewLayer removeFromSuperlayer];
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
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeCode39Code] || [[metadataObj type] isEqualToString:AVMetadataObjectTypeCode39Mod43Code]) {
            
            [self.statusLabel performSelectorOnMainThread:@selector(setText:) withObject:[metadataObj stringValue] waitUntilDone:NO];

            [self performSelectorOnMainThread:@selector(stopReading) withObject:nil waitUntilDone:NO];
            
            [self performSelector:@selector(delegateReadedCode:)
                       withObject:[metadataObj stringValue]];
            
            _isReading = NO;

        }
    }
}


/**
 *  Inform the delegate that the metadata object was read
 *
 *  @param readedCode decoded metadata message
 */
- (void) delegateReadedCode: (NSString*) readedCode {
    [self.delegate productsScannerViewController:self
                                   didReadString:readedCode];
}

@end
