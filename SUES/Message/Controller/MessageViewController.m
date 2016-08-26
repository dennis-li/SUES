//
//  MessageViewController.m
//  SUES
//
//  Created by lixu on 16/8/25.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import "MessageViewController.h"

@interface MessageViewController ()
@property (nonatomic,assign) CGFloat statusHeight;
@property (nonatomic,assign) CGFloat navHeight;
@property (nonatomic,assign) CGFloat tabBarHeight;
@end

@implementation MessageViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //获取当前状态栏的高度
    self.statusHeight = [[UIApplication sharedApplication]statusBarFrame].size.height;
    //获取导航栏的高度
    self.navHeight = self.navigationController.navigationBar.frame.size.height;
    //标签栏高度
    self.tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    
    self.view.backgroundColor = [UIColor purpleColor];
}
@end
