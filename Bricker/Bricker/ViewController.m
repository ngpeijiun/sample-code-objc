//
//  ViewController.m
//  Bricker
//
//  Created by Ng Pei Jiun on 1/5/15.
//  Copyright (c) 2015 SampleCode. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];

    self.gameViewController = [[GameViewController alloc] init];

    [self.view addSubview:self.gameViewController.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
