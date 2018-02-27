//
//  ViewController.m
//  cyCookieSystem
//
//  Created by 叶子 on 2018/2/27.
//  Copyright © 2018年 叶子. All rights reserved.
//

#import "ViewController.h"
#import "loadViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)loadUrl:(id)sender {
    [self.navigationController pushViewController:[[loadViewController alloc]init] animated:YES];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
