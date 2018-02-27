//
//  loadViewController.m
//  cyCookieSystem
//
//  Created by 叶子 on 2018/2/27.
//  Copyright © 2018年 叶子. All rights reserved.
//

#import "loadViewController.h"

@interface loadViewController ()

@end

@implementation loadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.url = [NSURL URLWithString:@"http://demo.b2b2c.shopxx.net/"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
