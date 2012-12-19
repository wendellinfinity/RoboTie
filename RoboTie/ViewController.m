/*
 ViewController.m
 RoboTie
 
 Created by Wendell on 12/19/12.
 Copyright (c) 2012 Wendell. All rights reserved.
 Simple Accelerometer code from: http://www.ifans.com/forums/threads/tutorial-simple-accelerometer-source-code.151394/
 NSStream Code from: http://www.raywenderlich.com/3932/how-to-create-a-socket-based-iphone-app-and-server
 */

#import "ViewController.h"
#define kAccelerometerFrequency 5
// High-pass filter constant
#define HIGHPASS_FILTER 0.1

@interface ViewController () {
    double zaxis;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initNetworkCommunication];
    
    [[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / kAccelerometerFrequency)];
    [[UIAccelerometer sharedAccelerometer] setDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma Actions
-(IBAction)toggleSettings: (id)sender {
    // turn off accel
    // disable auto segue!
}

-(IBAction)toggleConnect: (id)sender {
    
}

#pragma Communications

- (void)initNetworkCommunication {
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"192.168.1.3", 8888, &readStream, &writeStream);
    inputStream = (__bridge NSInputStream *)readStream;
    outputStream = (__bridge NSOutputStream *)writeStream;
    
    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
    
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [inputStream open];
    [outputStream open];
    
}

- (void)send:(NSString *)message {
    NSString *response  = [NSString stringWithFormat:@"[%@]", message];
	NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
	[outputStream write:[data bytes] maxLength:[data length]];
}

#pragma NSStream delegates
- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    
	switch (streamEvent) {
            
		case NSStreamEventOpenCompleted:
			NSLog(@"Stream opened");
			break;
            
		case NSStreamEventHasBytesAvailable:
            if (theStream == inputStream) {
                
                uint8_t buffer[1024];
                int len;
                
                while ([inputStream hasBytesAvailable]) {
                    len = [inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0) {
                        
                        NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                        
                        if (nil != output) {
                            NSLog(@"server said: %@", output);
                        }
                    }
                }
            }
            break;
            
		case NSStreamEventErrorOccurred:
			NSLog(@"Can not connect to the host!");
			break;
            
		case NSStreamEventEndEncountered:
            [theStream close];
            [theStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
			break;
            
		default:
			NSLog(@"Unknown event");
	}
    
}


#pragma Accelerometer delegates
// UIAccelerometerDelegate method, called when the device accelerates.
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    // Update the accelerometer graph view
    // FILTER from http://mobiledevelopertips.com/user-interface/accelerometer-101.html
    zaxis = acceleration.z - ((acceleration.z * HIGHPASS_FILTER) + (zaxis * (1.0 - HIGHPASS_FILTER)));
    [self send:[NSString stringWithFormat:@"%f", zaxis]];
    
}

@end
