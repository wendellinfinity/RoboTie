//
//  SettingsViewController.m
//  RoboTie
//
//  Created by Wendell on 12/19/12.
//  Copyright (c) 2012 Wendell. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)saveSettings: (id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
