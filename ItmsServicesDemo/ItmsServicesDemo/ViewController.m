//
//  ViewController.m
//  ItmsServicesDemo
//
//  Created by zhuge.zzy on 12/4/15.
//  Copyright © 2015 arbullzhang. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)checkUpdate:(id)sender
{
    [((AppDelegate *)[UIApplication sharedApplication].delegate) checkUpdate];
}

@end
