/*
 ViewController.h
 RoboTie
 
 Created by Wendell on 12/19/12.
 Copyright (c) 2012 Wendell. All rights reserved.
 ICON Images from: http://sxc.hu/photo/1400657 http://sxc.hu/photo/718959
 
 */


#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <NSStreamDelegate, UIAccelerometerDelegate> {
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
    NSString *ipAddress;
}

@property (strong, nonatomic) IBOutlet UIButton *connectButton;
@property (strong, nonatomic) IBOutlet UIButton *activateButton;
@property (strong, nonatomic) IBOutlet UIButton *resetButton;

@property (strong, nonatomic) IBOutlet UILabel *status;
@property (strong, nonatomic) IBOutlet UILabel *zaxisDisplay;

-(IBAction)toggleConnect: (id)sender;
-(IBAction)resetTie: (id)sender;
-(IBAction)toggleSettings: (id)sender;

@end
