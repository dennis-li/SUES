//
//  TimetableViewController.m
//  gcdqn
//
//  Created by admin on 16/7/19.
//  Copyright © 2016年 hardtosaygoodbye. All rights reserved.
//

#import "TimetableViewController.h"
#import "WeekView.h"
#import "Public.h"
#import "Courses+Flickr.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "Networking.h"


@interface TimetableViewController ()
@property (nonatomic,strong) Networking *networking;
@property (nonatomic,strong) WeekView *weekView;
@property (nonatomic,strong) NSString *userPassWord;
@property (nonatomic, strong) NSString *userId;
@end

@implementation TimetableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"viewDid");
    [self observerNotification];
    self.view.backgroundColor=[UIColor blueColor];
    //获取当前状态栏的高度
    CGRect statusRect = [[UIApplication sharedApplication]statusBarFrame];
    NSLog(@"状态栏高度：%f",statusRect.size.height);
    //获取导航栏的高度
    CGRect navRect = self.navigationController.navigationBar.frame;
    NSLog(@"导航栏高度：%f",navRect.size.height);
    
    CGRect tabBarRect = self.tabBarController.tabBar.frame;
    NSLog(@"标签栏高度：%f",tabBarRect.size.height);
    [self createRefreshButton];
    WeekView *weekView = [[WeekView alloc]initWithFrame:CGRectMake(0, statusRect.size.height+navRect.size.height, self.view.frame.size.width, self.view.frame.size.height-(statusRect.size.height+navRect.size.height+tabBarRect.size.height))];
    self.weekView = weekView;
    
    [self refreshWeekView];
    
    [self createNextWeekButton];

}

-(Networking *)networking
{
    if (!_networking) {
        _networking = [[Networking alloc] init];
    }
    return _networking;
}

-(User *)user
{
    if (!_user) {
        AppDelegate *app = [[UIApplication sharedApplication] delegate];
        _user = app.user;
    }
    return _user;
}

//刷新成绩
-(void)createRefreshButton
{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 40)];
    [btn setTitle:@"刷新" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(requestNetworking) forControlEvents:UIControlEventTouchUpInside];
    [btn setTintColor:[UIColor blackColor]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}

-(void)requestNetworking
{
    __weak TimetableViewController *weakSelf = self;
    self.networking.requestFinish = ^(NSString *requestString,NSString *error){
        if (error) {
            MBProgressHUD *hud = [weakSelf displayHud];
            hud.label.text = NSLocalizedString(error, @"HUD message title");
        }
    };
    [self.networking refreshHtmlDataWithNetworkingType:RefreshCourse];
}

-(void)observerNotification
{
    
    [[NSNotificationCenter defaultCenter]
     addObserverForName:@"sendContextToCourseTable"
     object:nil
     queue:nil
     usingBlock:^(NSNotification * _Nonnull note) {
         NSLog(@"notification");
         self.managedObjectContext = note.userInfo[@"context"];
         NSLog(@"notificationContext");
     }];
}

-(void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSLog(@"setContext");
    _managedObjectContext = managedObjectContext;
    self.weekView.currentWeek = @"0";
    [self refreshWeekView];
    MBProgressHUD *hud = [self displayHud];
    hud.label.text = NSLocalizedString(@"课表已更新", @"HUD message title");
}

//切换周数，按钮
-(void)createNextWeekButton
{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 40)];
    [btn setTitle:@"下一周" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(refreshWeekView) forControlEvents:UIControlEventTouchUpInside];
    [btn setTintColor:[UIColor blackColor]];
    self.navigationItem.titleView = btn;
}

-(void)refreshWeekView
{
    CGRect rect = self.weekView.frame;
    NSString *currentWeek = [NSString stringWithFormat:@"%ld",[self.weekView.currentWeek integerValue] + 1];
    [self.weekView removeFromSuperview];
    WeekView *weekView = [[WeekView alloc] initWithFrame:rect];
    [self.view addSubview:weekView];
    self.weekView = weekView;
    weekView.ctrl = self;
    weekView.currentWeek = currentWeek;
    weekView.user = self.user;
}

//显示一个弹窗
-(MBProgressHUD *)displayHud
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.offset = CGPointMake(0.f, -0.f);
    [hud hideAnimated:YES afterDelay:0.8f];
    return hud;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated
{
    CATransition *transition = [CATransition animation];
    [transition setDuration:0.5f];
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromRight;
    [self.tabBarController.view.layer addAnimation:transition forKey:nil];
}

@end
