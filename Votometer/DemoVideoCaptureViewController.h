//
//  DemoVideoCaptureViewController.h
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

#import "VideoCaptureViewController.h"
#import "AutoScrollLabel.h"
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>

// Our conversion definition
#define DEGREES_TO_RADIANS(angle) (angle / 180.0 * M_PI)

@interface DemoVideoCaptureViewController : VideoCaptureViewController <AVAudioRecorderDelegate, AVAudioPlayerDelegate>
{
    cv::CascadeClassifier _faceCascade;
    UIImageView *_imageToMove;
    int _counter;
 
    UIButton *playButton;
    UIButton *recordButton;
    UIButton *stopButton;
    
    AVAudioRecorder *audioRecorder;
    AVAudioPlayer *audioPlayer;
    
    NSString *soundFilePath;
    
    NSArray *_dataSource;
    AutoScrollLabel *_scroller;
    
}

@property (nonatomic, retain) UIImageView *_imageToMove;
@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) IBOutlet UIButton *recordButton;
@property (strong, nonatomic) IBOutlet UIButton *stopButton;
@property (nonatomic, retain) NSArray *dataSource;
@property (nonatomic, retain) AutoScrollLabel *scroller;


@property (strong, nonatomic) AVAudioRecorder *audioRecorder;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) NSString *soundFilePath;

- (IBAction)toggleFps:(id)sender;
- (IBAction)toggleTorch:(id)sender;
- (IBAction)toggleCamera:(id)sender;
- (BOOL)isRed:(int)red :(int)green :(int)blue;
- (BOOL)isGreen:(int)red :(int)green :(int)blue;
- (BOOL)isWhite:(int) red:(int)green :(int)blue;
- (void)processFrame:(cv::Mat &)mat videoRect:(CGRect)rect videoOrientation:(AVCaptureVideoOrientation)videOrientation;

- (void)rotateImage:(UIImageView *)image duration:(NSTimeInterval)duration
             curve:(int)curve degrees:(CGFloat)degrees;
//- (void)animationDidStop:(NSString*)animationID finished:(BOOL)finished context:(void *)context;

-(void)initAudioRecorder;
-(IBAction) recordAudio;
-(IBAction) playAudio;
-(IBAction) stop;


@end
