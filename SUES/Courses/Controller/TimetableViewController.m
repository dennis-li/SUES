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
#import "MyUtil.h"
#import "MenuView.h"
#import "UsersView.h"
#import "AnalyzeCourseData.h"

@interface TimetableViewController ()
@property (nonatomic,assign) CGFloat statusHeight;
@property (nonatomic,assign) CGFloat navHeight;
@property (nonatomic,assign) CGFloat tabBarHeight;
@property (nonatomic,strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,strong) User *user;
@property (nonatomic,strong) UsersView *usersView;//显示所有用户
@property (nonatomic,strong) MenuView *menu;//usersView的载体
@property (nonatomic,strong) Networking *networking;//网络活动
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
    self.statusHeight = [[UIApplication sharedApplication]statusBarFrame].size.height;
    //获取导航栏的高度
    self.navHeight = self.navigationController.navigationBar.frame.size.height;
    //标签栏高度
    self.tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    [self createRefreshButton];
    WeekView *weekView = [[WeekView alloc]initWithFrame:CGRectMake(0, self.statusHeight+self.navHeight, self.view.frame.size.width, self.view.frame.size.height-(self.statusHeight+self.tabBarHeight))];
    self.weekView = weekView;
    
    [self refreshWeekView];
    
    [self createNextWeekButton];//下一周按钮
    [self createUsersButton];

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
    return [self returnApp].user;
}

-(AppDelegate *)returnApp
{
    return [[UIApplication sharedApplication] delegate];
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
        if (!error) {
            [weakSelf requestRefreshCourseData];
        }
    };
    [self.networking requestRefresh];
}

-(void)requestRefreshCourseData
{
    self.networking.requestHtmlData = ^(NSData *gradeData,NSData *coursesData){
        AnalyzeCourseData *analyzeCourses = [[AnalyzeCourseData alloc] init];
        [analyzeCourses analyzeCoursesHtmlData:coursesData];
    };
    [self.networking requestUserDataWithType:RefreshCourse];
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

-(void)createUsersButton
{
    UIButton *btn = [MyUtil createBtnFrame:CGRectMake(0, 8, 30, 28) type:UIButtonTypeCustom bgImageName:@"myForum" title:nil target:self action:@selector(back)];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = item;
    
    UsersView *usersView = [[UsersView alloc]initWithFrame:CGRectMake(0, self.statusHeight+self.navHeight, [[UIScreen mainScreen] bounds].size.width * 0.8, [[UIScreen mainScreen] bounds].size.height)];
    MenuView *menu = [MenuView MenuViewWithDependencyView:self.view MenuView:usersView isShowCoverView:NO];
    self.menu = menu;
}

-(void)back
{
    if (self.menu.coverView.alpha > 0) {
        [self.menu hidenWithAnimation];
    } else {
        [self.menu show];
    }
}
@end
