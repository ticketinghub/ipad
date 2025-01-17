//
//  BarcodeViewController.m
//  TicketingHub
//
//  Created by Mark on 08/07/2013.
//  Copyright (c) 2013 TicketingHub. All rights reserved.
//

#import "TXHBarcodeScanner.h"

#import <AVFoundation/AVFoundation.h>

@interface TXHBarcodeScanner () <AVCaptureMetadataOutputObjectsDelegate>

@property (strong, nonatomic) AVCaptureDevice* device;
@property (strong, nonatomic) AVCaptureDeviceInput* input;
@property (strong, nonatomic) AVCaptureMetadataOutput* output;
@property (strong, nonatomic) AVCaptureSession* session;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer* preview;

@property (strong, nonatomic) UITapGestureRecognizer *tapRecognizer;

@property (assign, nonatomic) BOOL isTorch;

@end


@implementation TXHBarcodeScanner

- (instancetype)init
{
    if (!(self = [super init]))
        return nil;
    
    [self setupScanner];
    
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
    
    return self;
}

#pragma mark - AVFoundationSetup

- (void) setupScanner;
{
    self.device  = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.input   = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    self.session = [[AVCaptureSession alloc] init];
    self.output  = [[AVCaptureMetadataOutput alloc] init];

    [self.session addOutput:self.output];
    [self.session addInput:self.input];
    
    self.isTorch = NO;
    
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    self.output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode];
}

#pragma mark - Methods

- (void)setInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    [self setVideoOrientation:[self videoOrientationFortInterfaceOrientation:orientation]];
}

+ (BOOL)isCameraAvailable;
{
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    return [videoDevices count] > 0;
}

- (void)torch:(BOOL)enable
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch]) {
        [device lockForConfiguration:nil];
        [device setTorchMode: enable ? AVCaptureTorchModeOn : AVCaptureTorchModeOff];
        self.isTorch = enable;
        [device unlockForConfiguration];
    }
}

- (void)startScanning;
{
    [self.session startRunning];
}

- (void)stopScanning;
{
    [self.session stopRunning];
}

- (void)tapRecognized:(UITapGestureRecognizer *)tapRecognizer
{
    CGPoint locationInView = [tapRecognizer locationInView:tapRecognizer.view];
    [self focusAtPoint:locationInView];
    [self torch:!self.isTorch];
}

- (void)focusAtPoint:(CGPoint) aPoint;
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if([device isFocusPointOfInterestSupported] &&
       [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        double screenWidth = self.preview.bounds.size.width;
        double screenHeight = self.preview.bounds.size.height;
        double focus_x = aPoint.x/screenWidth;
        double focus_y = aPoint.y/screenHeight;
        if([device lockForConfiguration:nil]) {
            [device setFocusPointOfInterest:CGPointMake(focus_x,focus_y)];
            [device setFocusMode:AVCaptureFocusModeAutoFocus];
            if ([device isExposureModeSupported:AVCaptureExposureModeAutoExpose]){
                [device setExposureMode:AVCaptureExposureModeAutoExpose];
            }
            [device unlockForConfiguration];
        }
    }
}

- (void)showPreviewInView:(UIView *)view
{
    [self.preview removeFromSuperlayer];
    self.preview = nil;
    
    if (view)
    {
        self.preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.preview.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
        
        UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        [self setInterfaceOrientation:interfaceOrientation];
        
        [view.layer insertSublayer:self.preview atIndex:0];
    }
    
    [self.tapRecognizer.view removeGestureRecognizer:self.tapRecognizer];
    [view addGestureRecognizer:self.tapRecognizer];
}

- (void)setVideoOrientation:(AVCaptureVideoOrientation)orientation
{
    AVCaptureConnection *con = self.preview.connection;
    con.videoOrientation = orientation;
}

- (AVCaptureVideoOrientation)videoOrientationFortInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    
    AVCaptureVideoOrientation newOrientation = AVCaptureVideoOrientationLandscapeRight;
    
    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft){
        newOrientation = AVCaptureVideoOrientationLandscapeLeft;
    }
    else if (interfaceOrientation == UIInterfaceOrientationLandscapeRight){
        newOrientation = AVCaptureVideoOrientationLandscapeRight;
    }
    
    return newOrientation;
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection
{
    for (AVMetadataObject *current in metadataObjects)
    {
        if ([current isKindOfClass:[AVMetadataMachineReadableCodeObject class]])
        {
            NSString *scannedValue = [((AVMetadataMachineReadableCodeObject *) current) stringValue];            
            if ([self.delegate respondsToSelector:@selector(scanViewController:didSuccessfullyScan:)])
            {
                [self.delegate scanViewController:self didSuccessfullyScan:scannedValue];
            }
        }
    }
}

@end
