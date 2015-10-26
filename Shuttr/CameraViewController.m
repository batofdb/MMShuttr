//
//  CameraViewController.m
//  Shuttr
//
//  Created by Lin Wei on 10/22/15.
//  Copyright © 2015 MMInstaGroup. All rights reserved.
//

#import "CameraViewController.h"
#import "PostPhotosViewController.h"
#import "UIImage+ImageResizing.h"
@interface CameraViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate>{
   
    AVCaptureSession * session;
    AVCaptureStillImageOutput *stillImageOutput;
    SystemSoundID soundID;
    BOOL flashlightOn;
 
}

@property (weak, nonatomic) IBOutlet UIButton *skip;
@property (weak, nonatomic) IBOutlet UIImageView *wheelImageView;

@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@property (strong, nonatomic) IBOutlet UIImageView *imageView;

- (IBAction)takePhoto:  (UIButton *)sender;
- (IBAction)selectPhoto:(UIButton *)sender;

@property (nonatomic)NSArray *shutterImageArray;
@property NSMutableArray * photoArray;

@property (nonatomic)NSMutableArray * photoImageArrayB;

@property int imageCount;

@property (weak, nonatomic) IBOutlet UIImageView *shutterImageView;

@end




@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //music url
    
    NSURL *musicUrl=[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"shutterSoundEffect" ofType:@"mp3"]];
    
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)   musicUrl, &soundID);
    
//     self.photoImageArrayB = [NSMutableArray new];
//    for (int i = 1; i <79; i++) {
//        
//        NSString *imageName = [NSString stringWithFormat:@"lauch%d",i];
//        
//        [self.photoImageArrayB addObject:[UIImage imageNamed:imageName]];
//        
//    }
//    
    
  
    
    // shutter image sequence
    self.shutterImageArray = [NSArray arrayWithObjects: [UIImage imageNamed:@"shutter 1"],
  [UIImage imageNamed:@"shutter 2"],
                              [UIImage imageNamed:@"shutter 1"],
                              [UIImage imageNamed:@"shutter 4"],
                              [UIImage imageNamed:@"shutter 5"],
                              [UIImage imageNamed:@"shutter 6"],
                              [UIImage imageNamed:@"shutter 7"],
                              [UIImage imageNamed:@"shutter 8"],
                              [UIImage imageNamed:@"shutter 9"],
                              [UIImage imageNamed:@"shutter 10"],
                              [UIImage imageNamed:@"shutter 11"],
                              [UIImage imageNamed:@"shutter 12"],
                              
                              [UIImage imageNamed:@"shutter 13"],nil];
    
    self.imageCount =10;
    
   
 
    
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
//keep orientation portait
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
    
    // Use this to allow upside down as well
    //return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}


- (IBAction)skipButton:(UIButton *)sender {
    

    
    if (self.photoArray.count == 0) {
        
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Message" message:@"Need at least one image taken" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
        
        [alert addAction:action];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    else{
    [self performSegueWithIdentifier:@"ToPostSegue" sender:self];
    self.photoArray = [NSMutableArray new];
    }

}

#pragma mark resize Images

//+ (UIImage*)imageWithImage:(UIImage*)image
//              scaledToSize:(CGSize)newSize;
//{
//    UIGraphicsBeginImageContext( newSize );
//    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
//    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    return newImage;
//}




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
//             self.imageView.image = image;
             
             //resize image
             CGSize imageSize = CGSizeMake(400, 400);
             UIImage *newImage = [UIImage imageWithImage:image scaledToSize:imageSize];
             
             
             [self.photoArray addObject: newImage];
              //save image to photosAlbum
//             UIImageWriteToSavedPhotosAlbum (self.imageView.image, nil, nil , nil);
             
             //segue when image reaches to 10
             if (self.photoArray.count == self.imageCount) {
           
             [self performSegueWithIdentifier:@"ToPostSegue" sender:self];
                    self.photoArray = [NSMutableArray new];
              self.countLabel.text = [NSString stringWithFormat:@"Count: 0" ];
             
                 
             }
          }
      }];
    
    self.countLabel.text = [NSString stringWithFormat:@"Count: %lu",(unsigned long)self.photoArray.count+1];
    //animate shutter
    
    
//    self.shutterImageView.animationImages = self.photoImageArrayB;
    
    self.shutterImageView.animationImages = self.shutterImageArray;
    self.shutterImageView.animationDuration = 1;
    self.shutterImageView.animationRepeatCount = 1;
    [self.shutterImageView startAnimating];
    
    
    
    
    
    //flash
    
    //    if (flashlightOn == NO)
    //    {   [self toggleFlashlight];
    //        flashlightOn = YES;
    //
    //    }
    //    else
    //    {
    //        flashlightOn = NO;
    //
    //        [self toggleFlashlight];
    //    }
    //    
    //    [self toggleFlashlight];
    //soundeffect
    
//        AudioServicesPlaySystemSound(soundID);
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

    PostPhotosViewController * postPhotoViewcontroller = segue.destinationViewController;
    postPhotoViewcontroller.images = self.photoArray;
    NSLog(@"%lu",(unsigned long)postPhotoViewcontroller.images.count);
    self.countLabel.text = [NSString stringWithFormat:@"Count: 0" ];
}




@end
