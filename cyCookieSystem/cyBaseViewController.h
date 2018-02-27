//
//  cyBaseViewController.h
//  cyCookieSystem
//
//  Created by 叶子 on 2018/2/27.
//  Copyright © 2018年 叶子. All rights reserved.
//

#import <UIKit/UIKit.h>
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
#define cyWeakSelf(weakSelf)  __weak __typeof(&*self)weakSelf = self;  // 弱引用
#ifdef DEBUG // 开发
#define CYLog(...) NSLog(@"%s %d \n%@\n\n",__func__,__LINE__,[NSString stringWithFormat:__VA_ARGS__])
#else // 生产
#define CYLog(...) //NSLog(@"%s %d \n%@\n\n",__func__,__LINE__,[NSString stringWithFormat:__VA_ARGS__])
#endif
@interface cyBaseViewController : UIViewController
@property (nonatomic,strong) NSURL * url;
@end
