//
//  BaseViewController.m
//  SohuByObject_C
//
//  Created by lixu on 16/4/8.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import "BaseViewController.h"
#import "MyUtil.h"
#import "AppDelegate.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //获取当前状态栏的高度
    self.statusHeight = [[UIApplication sharedApplication]statusBarFrame].size.height;
    //获取导航栏的高度
    self.navHeight = self.navigationController.navigationBar.frame.size.height;
    //标签栏高度
    self.tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    self.screenWidth = [UIScreen mainScreen].bounds.size.width;
    self.screenHeight = [UIScreen mainScreen].bounds.size.height;
    //设置基本视图控制器基本颜色
    self.view.backgroundColor = [UIColor whiteColor];
}

-(User *)user
{
    return [self returnApp].user;
}

-(AppDelegate *)returnApp
{
    return [[UIApplication sharedApplication] delegate];
}

//添加标题
-(void)addNavTitle:(NSString *)title
{
    UILabel *label = [MyUtil createLabelFrame:CGRectMake(ScreenWidth/3, 0, ScreenWidth/3, self.navHeight) title:title];//label占屏幕宽度1/3
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:self.navHeight/2];
    label.textColor = [UIColor grayColor];
    self.navigationItem.titleView = label;
}

//添加导航按钮
-(UIButton *)addNavBtn:(NSString *)imageName target:(id)target action:(SEL)action isLeft:(BOOL)isLeft
{
    UIButton *btn = [MyUtil createBtnFrame:CGRectMake(0, 8, 30, 28) type:UIButtonTypeCustom bgImageName:imageName title:nil target:target action:action];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    if (isLeft) {
        self.navigationItem.leftBarButtonItem = item;
    } else {
        self.navigationItem.rightBarButtonItem = item;
    }
    return btn;
}

//添加返回按钮
-(void)addBackBtn:(NSString *)imageName target:(id)target action:(SEL)action
{
    [self addNavBtn:imageName target:target action:action isLeft:YES];
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
