//
//  TimetableViewController.m
//  gcdqn
//
//  Created by admin on 16/7/19.
//  Copyright © 2016年 hardtosaygoodbye. All rights reserved.
//

#import "TimetableViewController.h"
#import "WeekView.h"
#import <AFNetworking.h>
#import "TFHpple.h"
#import "Public.h"
#import "CreateContext.h"
#import "Courses+Flickr.h"
#import "AppDelegate.h"
#import "UpdateUserView.h"
#import "SwipeView.h"


@interface TimetableViewController ()

@property (nonatomic,strong) NSMutableArray *coursesArray;
@property (nonatomic,strong) NSMutableDictionary *courseDictionary;
@property (nonatomic,strong) NSMutableDictionary *userDictionary;
@property (nonatomic,strong) NSString *urlString;
@property (nonatomic,strong) UIWebView *webView;
@property (nonatomic,strong) WeekView *weekView;
@property (nonatomic,strong) UpdateUserView *addUserView;
@property (nonatomic,strong) NSString *userPassWord;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic,strong) UpdateUserView *signInView;
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
    
    WeekView *weekView = [[WeekView alloc]initWithFrame:CGRectMake(0, statusRect.size.height+navRect.size.height, self.view.frame.size.width, self.view.frame.size.height-(statusRect.size.height+navRect.size.height+tabBarRect.size.height))];
    self.weekView = weekView;
    
    [self refreshWeekView];
    
    [self createNextWeekButton];

}

-(User *)user
{
    if (!_user) {
        AppDelegate *app = [[UIApplication sharedApplication] delegate];
        _user = app.user;
    }
    return _user;
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

-(void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSLog(@"setContext");
    _managedObjectContext = managedObjectContext;
    [self refreshWeekView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





@end
