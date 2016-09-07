//
//  MainTabBarController.m
//  SUES
//
//  Created by lixu on 16/8/15.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import "MainTabBarController.h"

@interface MainTabBarController ()

@end

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tabBar.backgroundImage = [[UIImage imageNamed:@"tabbar"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    
    //创建视图控制器
    [self createViewControllers];
}

//创建视图控制器
-(void)createViewControllers
{
    NSArray *ctrlArray = @[@"CourseViewController",@"GradeTableViewController",@"MessageViewController",@"MineViewController"];
    NSArray *titleArray = @[@"课表",@"成绩",@"考试",@"设置"];
    NSArray *imageArray = @[@"document_normal",@"check_normal",@"exam_normal",@"gear_normal"];
    NSArray *selctImageArray = @[@"document",@"check",@"exam",@"gear"];
    NSMutableArray *array = [NSMutableArray array];
    for (int i=0; i<ctrlArray.count; i++) {
        
        //把字符串转换成类
        Class cls = NSClassFromString(ctrlArray[i]);
        UIViewController *vc  = [[cls alloc] init];
        vc.tabBarItem.title = titleArray[i];
        
        vc.tabBarItem.image = [[UIImage imageNamed:imageArray[i]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        vc.tabBarItem.selectedImage = [[UIImage imageNamed:selctImageArray[i]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:vc];
        [array addObject:navCtrl];
    }
    self.viewControllers = array;
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor grayColor],NSForegroundColorAttributeName,nil]forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor orangeColor],NSForegroundColorAttributeName,nil]forState:UIControlStateSelected];
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
