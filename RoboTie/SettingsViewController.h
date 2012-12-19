//
//  SettingsViewController.h
//  RoboTie
//
//  Created by Wendell on 12/19/12.
//  Copyright (c) 2012 Wendell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *ipAddress;

-(IBAction)saveSettings: (id)sender;

@end
