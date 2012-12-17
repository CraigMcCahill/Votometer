//
//  DemoVideoCaptureViewController.m
//  FaceTracker
//
//  Created by Robin Summerhill on 9/22/11.
//  Copyright 2011 Aptogo Limited. All rights reserved.
//
//  Permission is given to use this source code file without charge in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import "UIImage+OpenCV.h"

#import "DemoVideoCaptureViewController.h"

// Name of face cascade resource file without xml extension
//NSString * const kFaceCascadeFilename = @"haarcascade_frontalface_alt2";

// Options for cv::CascadeClassifier::detectMultiScale
//const int kHaarOptions =  CV_HAAR_FIND_BIGGEST_OBJECT | CV_HAAR_DO_ROUGH_SEARCH;
/*
@interface DemoVideoCaptureViewController ()
- (void)displayFaces:(const std::vector<cv::Rect> &)faces 
       forVideoRect:(CGRect)rect 
    videoOrientation:(AVCaptureVideoOrientation)videoOrientation;
@end
*/

@implementation DemoVideoCaptureViewController

@synthesize _imageToMove;
@synthesize dataSource = _dataSource;
@synthesize scroller = _scroller;
@synthesize playButton, stopButton, recordButton;
@synthesize audioPlayer, audioRecorder, soundFilePath;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //self.captureGrayscale = YES;
        self.captureGrayscale = NO;
        self.qualityPreset = AVCaptureSessionPresetMedium;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //buttons for audio recording
    playButton.enabled = NO;
    stopButton.enabled = NO;
    
    playButton.alpha = 0.4;
    stopButton.alpha = 0.4;
    
    
    // Load the face Haar cascade from resources
    /*
    NSString *faceCascadePath = [[NSBundle mainBundle] pathForResource:kFaceCascadeFilename ofType:@"xml"];
    
    if (!_faceCascade.load([faceCascadePath UTF8String])) {
        NSLog(@"Could not load face cascade: %@", faceCascadePath);
    }
    */
    
    
    //swingometer
    _imageToMove = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"votometer_needle.png"]];
    
    _imageToMove.frame = CGRectMake(489, 270, 48, 439);
    [self.view addSubview:_imageToMove];
    [_imageToMove.layer setAnchorPoint:CGPointMake(0.5, 0.94)];
    _counter = 1;
    
    
    //scroller lavle for twitter
    _scroller = [[AutoScrollLabel alloc] initWithFrame:CGRectMake(30, 530, 968, 150)];
    [_scroller setText:@"Please tweet the speaker at @Soap_Vox, show green to show approval, red to show dissent."];
    [_scroller setTextColor:[UIColor blackColor]];
    
    [self.view addSubview:_scroller];
    
    
    UIFont *lucetita = [UIFont
                          fontWithName:@"Lucecita-Healthy"
                          size:72.0f];
    _scroller.font = lucetita;
    
    
    
    
    //NSString *soundFilePath = [docsDir stringByAppendingPathComponent:@"sound.caf"];
    //NSString timestamp = @"";
    
        
    _videoPreviewLayer.hidden = _hideVideo;
    [self.view.layer insertSublayer:_videoPreviewLayer atIndex:3];
    //_videoPreviewLayer.= [self affineTransformForVideoFrame:_videoPreviewLayer.frame orientation:AVCaptureVideoOrientationLandscapeLeft];

    

}

- (void)viewDidUnload
{
    [super viewDidUnload];
}


-(void)initAudioRecorder
{
    NSArray *dirPaths;
    NSString *docsDir;
    
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    
    NSTimeInterval  now = [[NSDate date] timeIntervalSince1970];
    NSString *intervalString = [NSString stringWithFormat:@"%f", now];
    NSString *filename = [intervalString stringByAppendingString:@"_speech.caf"];
    soundFilePath = [docsDir stringByAppendingPathComponent:filename];
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    
    NSDictionary *recordSettings = [NSDictionary
                                    dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:AVAudioQualityMin],
                                    AVEncoderAudioQualityKey,
                                    [NSNumber numberWithInt:16],
                                    AVEncoderBitRateKey,
                                    [NSNumber numberWithInt: 1],
                                    AVNumberOfChannelsKey,
                                    [NSNumber numberWithFloat:32000.0],
                                    AVSampleRateKey,
                                    [NSNumber numberWithInt: kAudioFormatMPEG4AAC],
                                    AVFormatIDKey,
                                    nil];
    
    NSError *error = nil;
    
    audioRecorder = [[AVAudioRecorder alloc]
                     initWithURL:soundFileURL
                     settings:recordSettings
                     error:&error];
    
    if (error)
    {
        NSLog(@"error: %@", [error localizedDescription]);
    } else {
        [audioRecorder prepareToRecord];
    }

}

-(void) recordAudio
{
    if (!audioRecorder.recording)
    {
        [self initAudioRecorder];
        
        playButton.enabled = NO;
        stopButton.enabled = YES;
        recordButton.enabled = NO;
        playButton.alpha = 0.4;
        stopButton.alpha = 1.0;
        recordButton.alpha = 0.4;
        [audioRecorder record];
    }
}


-(void)stop
{
    stopButton.enabled = NO;
    stopButton.alpha = 0.4;
    playButton.enabled = YES;
    playButton.alpha = 1.0;
    recordButton.enabled = YES;
    recordButton.alpha = 1.0;
    
    if (audioRecorder.recording)
    {
        [audioRecorder stop];
    } else if (audioPlayer.playing) {
        [audioPlayer stop];
    }
}


-(void) playAudio
{
    if (!audioRecorder.recording)
    {
        stopButton.enabled = YES;
        stopButton.alpha = 1.0;
        recordButton.enabled = NO;
        recordButton.alpha = 0.4;
        playButton.enabled = NO;
        playButton.alpha = 0.4;
        
        NSError *error;
        
        audioPlayer = [[AVAudioPlayer alloc]
                       initWithContentsOfURL:audioRecorder.url
                       error:&error];
        
        audioPlayer.delegate = self;
        
        if (error)
            NSLog(@"Error: %@",
                  [error localizedDescription]);
        else
            [audioPlayer play];
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    stopButton.enabled = NO;
    stopButton.alpha = 0.4;
    playButton.enabled = YES;
    playButton.alpha = 1.0;
    recordButton.enabled = YES;
    recordButton.alpha = 1.0;
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// MARK: IBActions

// Toggles display of FPS
- (IBAction)toggleFps:(id)sender
{
    self.showDebugInfo = !self.showDebugInfo;
}

// Turn torch on and off

- (IBAction)toggleTorch:(id)sender
{
    self.torchOn = !self.torchOn;
}
 
  
// Switch between front and back camera
- (IBAction)toggleCamera:(id)sender
    {
      if(_videoPreviewLayer.hidden)
      {
          _videoPreviewLayer.hidden = NO;
      }
      else
      {
          _videoPreviewLayer.hidden = YES;
      }
        
        /*
    if (self.camera == 1) {
        self.camera = 0;
    }
    else
    {
        self.camera = 1;
    }
         */
}


// MARK: VideoCaptureViewController overrides
- (void)processFrame:(cv::Mat &)mat videoRect:(CGRect)rect videoOrientation:(AVCaptureVideoOrientation)videOrientation
{
    
    int red = 0;
    int blue = 0;
    int green = 0;

    int redTotal = 0;
    int greenTotal = 0;
    
    for (int i = 0; i < mat.rows; i++)
    {
        for (int j = 0; j < mat.cols; j++)
        {
           blue = mat.at<cv::Vec4b>(i,j)[0]; // Blue
           green = mat.at<cv::Vec4b>(i,j)[1]; // Green
           red = mat.at<cv::Vec4b>(i,j)[2]; // Red
           
            
            if([self isRed:red :green :blue]) redTotal ++;
            else if([self isGreen:red :green :blue]) greenTotal ++;
         
        }
    }
    
    //the percentage of red
    float percentage;
    
    //check that we aren't in the dark and both are zero
    if(redTotal > 0 || greenTotal > 0)
    {
        float total = (redTotal+greenTotal);
        percentage = greenTotal / total;
        
    }
    else //if both are zero make percentage 50%
    {
        percentage = 0.50f;
    }
    
   
  
    if((_counter % 31) == 0)
    {
                    
        CGFloat degrees = (180*percentage) - 90.0f;
        
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self rotateImage:_imageToMove duration:1.0
                        curve:UIViewAnimationCurveEaseIn degrees:degrees];
        });
        
      
        NSLog(@"Degrees= %f", degrees);
    }
    _counter++;
    
}

-(BOOL) isWhite:(int) red:(int)green :(int)blue
{
    int threshold = 100;
    return (red > threshold && green > threshold && blue > threshold);
}

- (BOOL)isRed:(int)red :(int)green :(int)blue
{
    return ((red-green)+(red-blue) > 160);
    //return (red > green && red > blue && ![self isWhite:red :green :blue]);
}

- (BOOL)isGreen:(int)red :(int)green :(int)blue
{
    return ((green-red)+(green-blue) > 90);
    //return (green > red && green > blue && ![self isWhite:red :green :blue]);
}



- (void)rotateImage:(UIImageView *)image duration:(NSTimeInterval)duration
              curve:(int)curve degrees:(CGFloat)degrees
{
    // Setup the animation
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:curve];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    //event when animation ends
    [UIView setAnimationDelegate:self];
   // [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    
    // The transform matrix
    CGAffineTransform transform =
    CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(degrees));
    image.transform = transform;
    
    // Commit the changes
    [UIView commitAnimations];
}

- (IBAction)requestMentions:(id)sender {
    
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [accountStore requestAccessToAccountsWithType:accountType options:nil
                                            completion:^(BOOL granted, NSError *error)
    {
            if (granted)
            {
                NSArray *accounts = [accountStore accountsWithAccountType:accountType];
                if ([accounts count] > 0)
                {
                    ACAccount *twitterAccount = [accounts lastObject];
                                                        
                    NSURL *url = [NSURL URLWithString:@"http://api.twitter.com/1/statuses/mentions.json"];
                                                        
                    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
                    [parameters setObject:@"20" forKey:@"count"];
                    [parameters setObject:@"1" forKey:@"include_entities"];
                                                        
                    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:url parameters:parameters];
                                                        
                    request.account = twitterAccount;
                                                       
                    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
                    {
                        if (responseData)
                        {
                            NSError *error = nil;
                            self.dataSource = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                                                                
                            if (self.dataSource)
                            {
                                NSLog(@"Got data!");
                                
                                NSDictionary *tweet = [self.dataSource objectAtIndex:0];
                                [_scroller setText:[tweet objectForKey:@"text"]];
                                
                                
                                //cell.textLabel.text = [tweet objectForKey:@"text"];
                                
                                
                            }
                            else
                            {
                                NSLog(@"Error %@ with user info %@.", error, error.userInfo);
                            }
                        }
                    }];
                                                         

                }
            }
            else
            {
                NSLog(@"%@",error);
                // Fail gracefully...
            }
        }];
    
   }

@end
