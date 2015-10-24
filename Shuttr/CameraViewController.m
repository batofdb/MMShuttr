//
//  CameraViewController.m
//  Shuttr
//
//  Created by Lin Wei on 10/22/15.
//  Copyright © 2015 MMInstaGroup. All rights reserved.
//

#import "CameraViewController.h"
#import "PostPhotosViewController.h"
@interface CameraViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate>{
   
    AVCaptureSession * session;
    AVCaptureStillImageOutput *stillImageOutput;
    
    BOOL flashlightOn;
 
}

@property (weak, nonatomic) IBOutlet UIImageView *wheelImageView;

@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@property (strong, nonatomic) IBOutlet UIImageView *imageView;

- (IBAction)takePhoto:  (UIButton *)sender;
- (IBAction)selectPhoto:(UIButton *)sender;

@property NSMutableArray * photoArray;

@end




@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    
    //swipe gesture
    self.wheelImageView.userInteractionEnabled = YES;
    UISwipeGestureRecognizer *gestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandler:)];
    gestureRecognizer.delegate = self;
    [gestureRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.wheelImageView addGestureRecognizer:gestureRecognizer];
    
    //instantiate array
    self.photoArray = [NSMutableArray new];
    
 //AVCaptureSession preset
    session = [AVCaptureSession new];
    [session setSessionPreset:AVCaptureSessionPresetPhoto];
    
    AVCaptureDevice *inputDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError*error;
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:inputDevice error:&error];
    
    if ([session canAddInput:deviceInput]) {
        [session addInput:deviceInput];
        
    }
    
    AVCaptureVideoPreviewLayer * previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:session];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    CALayer *rootLayer = [[self view]layer];
    [rootLayer setMasksToBounds:YES];
    CGRect frame = self.view.frame;
    [previewLayer setFrame:frame];
    
    [rootLayer insertSublayer:previewLayer atIndex:0];
    
    
    stillImageOutput = [AVCaptureStillImageOutput new];
    NSDictionary *outputSetting  = [[NSDictionary alloc]initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
    [stillImageOutput setOutputSettings:outputSetting];
    
    [session addOutput:stillImageOutput];
    [session startRunning];

 
    
}


#pragma mark swipeSelector
-(void)swipeHandler:(UISwipeGestureRecognizer *)recognizer {
  
    
    NSLog(@"Swipe received.");
}


#pragma mark takePhoto
- (IBAction)takePhoto:(UIButton *)sender {
    
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in stillImageOutput.connections)
    {
        for (AVCaptureInputPort *port in [connection inputPorts])
        {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] )
            {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break;
        }
    }
    
    NSLog(@"about to request a capture from: %@", stillImageOutput);
    [stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection
                                                  completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
         
         if (imageSampleBuffer !=NULL)
         {
             NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
             UIImage *image = [[UIImage alloc] initWithData:imageData];
             self.imageView.image = image;
             
             
             [self.photoArray addObject: self.imageView];
              //save image to photosAlbum
             UIImageWriteToSavedPhotosAlbum (self.imageView.image, nil, nil , nil);
             
             //segue when image reaches to 10
             if (self.photoArray.count == 10) {
           
             [self performSegueWithIdentifier:@"ToPostSegue" sender:self];
                    self.photoArray = [NSMutableArray new];
             }
          }
      }];
    
    self.countLabel.text = [NSString stringWithFormat:@"Count: %lu",(unsigned long)self.photoArray.count+1];
    
}

#pragma mark selectPhoto

- (IBAction)selectPhoto:(UIButton *)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:NULL];
    
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

#pragma mark shakemMotion
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (UIEventSubtypeMotionShake) {
        AVCaptureConnection *videoConnection = nil;
        for (AVCaptureConnection *connection in stillImageOutput.connections)
        {
            for (AVCaptureInputPort *port in [connection inputPorts])
            {
                if ([[port mediaType] isEqual:AVMediaTypeVideo] )
                {
                    videoConnection = connection;
                    break;
                }
            }
            if (videoConnection) { break;
            }
        }
        
        NSLog(@"about to request a capture from: %@", stillImageOutput);
        [stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection
                                                      completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
         {
             
             if (imageSampleBuffer !=NULL)
             {
                 NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
                 UIImage *image = [[UIImage alloc] initWithData:imageData];
                 self.imageView.image = image;
                 
                 
                 [self.photoArray addObject: self.imageView];
                 //save image to photosAlbum
                 UIImageWriteToSavedPhotosAlbum (self.imageView.image, nil, nil , nil);
                 
                 //segue when image reaches to 10
                 if (self.photoArray.count == 10) {
                     
                     
                     [self performSegueWithIdentifier:@"ToPostSegue" sender:self];
                     self.photoArray = [NSMutableArray new];
                 }
             }
         }];
        NSLog(@"I'm shaking!");
        
        //flash
            if (flashlightOn == NO)
            {
                flashlightOn = YES;
                          }
            else
            {
                flashlightOn = NO;
             
            }
        
           [self toggleFlashlight];
        
         self.countLabel.text = [NSString stringWithFormat:@"Count: %lu",(unsigned long)self.photoArray.count+1];
        
    }
}



#pragma mark flashOnOff switch

- (void) toggleFlashlight  {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if (device.torchMode == AVCaptureTorchModeOff)
    {
        // Create an AV session
        AVCaptureSession *sessions = [[AVCaptureSession alloc] init];
        
        // Create device input and add to current session
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error: nil];
        [sessions addInput:input];
        
        // Create video output and add to current session
        AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
        [sessions addOutput:output];
        
        // Start session configuration
        [sessions beginConfiguration];
        [device lockForConfiguration:nil];
        
        // Set torch to on
        [device setTorchMode:AVCaptureTorchModeOn];
        
        [device unlockForConfiguration];
        [sessions commitConfiguration];
        
        // Start the session
        [sessions startRunning];
        
        // Keep the session around
        session = sessions;
      
    }
    else
    {
        [session stopRunning];
        
    }
}




#pragma mark picker delegate method

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
   
    UIImage *editedImage = [info objectForKey:UIImagePickerControllerEditedImage];
    [self.photoManager pinInBackground];
    self.imageView.image = editedImage;
   //save to photo album
    UIImageWriteToSavedPhotosAlbum (editedImage, nil, nil , nil);
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    
    PostPhotosViewController * postPhotoViewcontroller = [PostPhotosViewController new];
    
    postPhotoViewcontroller.images = self.photoArray;
    
    NSLog(@"%lu",(unsigned long)postPhotoViewcontroller.images.count);
}




@end
