/*
 ViewController.m
 RoboTie
 
 Created by Wendell on 12/19/12.
 Copyright (c) 2012 Wendell. All rights reserved.
 Simple Accelerometer code from: http://www.ifans.com/forums/threads/tutorial-simple-accelerometer-source-code.151394/
 NSStream Code from: http://www.raywenderlich.com/3932/how-to-create-a-socket-based-iphone-app-and-server
 */

#import "ViewController.h"
#define kAccelerometerFrequency 4
// High-pass filter constant
#define HIGHPASS_FILTER 0.1
#define INSTR_UP "UP"
#define INSTR_RESET "RESET"

@interface ViewController () {
    double zaxis;
    bool isConnected;
    int maxZ;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / kAccelerometerFrequency)];
    [[UIAccelerometer sharedAccelerometer] setDelegate:self];
    // init variables
    zaxis = 0;
    maxZ = 300;
    isConnected = NO;
    // initialize stream
    [self initNetworkCommunication];

}

- (void)viewWillDisappear:(BOOL)animated {
    if(isConnected) {
        [self disconnect];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma Actions
-(IBAction)toggleSettings: (id)sender {
    // turn off accel
    // disable auto segue!
}

-(void)connect {
    [self initNetworkCommunication];
    // open streams
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream open];
    [outputStream open];
}

-(void)disconnect {
    // close streams
    [inputStream close];
    [outputStream close];
    [inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    self.status.text = @"Disconnected";
    self.status.backgroundColor = [UIColor redColor];
    NSLog(@"Stream opened");
    // change button states
    [self.connectButton setTitle:@"Connect" forState:UIControlStateNormal];
    [self.connectButton setEnabled:YES];
    isConnected = NO;
   
}

-(IBAction)toggleConnect: (id)sender {
    [self.connectButton setEnabled:NO];
    if(!isConnected) {
        [self connect];
    } else {
        [self disconnect];
    }
}

-(IBAction)resetTie: (id)sender {
    if(isConnected) {
        [self send:[NSString stringWithFormat:@"%s", INSTR_RESET]];
    }
}

#pragma Communications

- (void)initNetworkCommunication {
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"169.254.1.1", 2000, &readStream, &writeStream);
    inputStream = (__bridge NSInputStream *)readStream;
    outputStream = (__bridge NSOutputStream *)writeStream;
    
    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
            
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
            self.status.text = @"Connected";
            self.status.backgroundColor = [UIColor greenColor];
			NSLog(@"Stream opened");
            // change button states
            [self.connectButton setTitle:@"Disconnect" forState:UIControlStateNormal];
            [self.connectButton setEnabled:YES];
            isConnected = YES;
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
            self.status.text = @"Connection failed";
            self.status.backgroundColor = [UIColor redColor];
			NSLog(@"Can not connect to the host!");
            // change button states
            [self.connectButton setTitle:@"Connect" forState:UIControlStateNormal];
            [self.connectButton setEnabled:YES];
			break;
            
		case NSStreamEventEndEncountered:

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
    self.zaxisDisplay.text = [NSString stringWithFormat:@"%d", (int)((zaxis / 1) * 100)];
    if(isConnected && ((zaxis / 1) * 100) < (maxZ * -1)) {
        [self send:[NSString stringWithFormat:@"%s", INSTR_UP]];
    }
}

@end
