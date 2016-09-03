//
//  MessageViewController.m
//  SUES
//
//  Created by lixu on 16/8/25.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import "MessageViewController.h"
#import "AnswerQeustionViewController.h"
#import "AppDelegate.h"
#import "Public.h"
#import "Exam.h"
#import "PublicCell.h"
#import "AnswerQuestion.h"

@interface MessageViewController ()
@property (nonatomic,assign) CGFloat statusHeight;
@property (nonatomic,assign) CGFloat navHeight;
@property (nonatomic,assign) CGFloat tabBarHeight;
@property (nonatomic,strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,strong) User *user;
@end

@implementation MessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self observerNotification];
    //获取当前状态栏的高度
    self.statusHeight = [[UIApplication sharedApplication]statusBarFrame].size.height;
    //获取导航栏的高度
    self.navHeight = self.navigationController.navigationBar.frame.size.height;
    //标签栏高度
    self.tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    
    [self createRefreshButton];
    self.managedObjectContext = self.user.managedObjectContext;
    self.navigationItem.title = @"考试安排";
}

-(User *)user
{
    return [self returnApp].user;
}

-(AppDelegate *)returnApp
{
    return [[UIApplication sharedApplication] delegate];
}

//注册通知
-(void)observerNotification
{
    
    [[NSNotificationCenter defaultCenter]
     addObserverForName:@"sendContextToForeground"
     object:nil
     queue:nil
     usingBlock:^(NSNotification * _Nonnull note) {
         self.managedObjectContext = note.userInfo[@"context"];
     }];
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

-(void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    NSFetchRequest *gradeRequest = [NSFetchRequest fetchRequestWithEntityName:@"Exam"];
    gradeRequest.predicate = [NSPredicate predicateWithFormat:@"whoExam = %@", self.user];
   
    gradeRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"semesterId"
                                                              ascending:NO
                                                               selector:@selector(localizedStandardCompare:)]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:gradeRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    [self.tableView reloadData];
}

//创建分组的标题
-(NSString *)createTitleForHeader:(NSString *)baseTitle
{
    return @"考试信息";
}

#pragma -mark UITableViewCell delegate
//显示数据
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"publicCellId";
    PublicCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"PublicCell" owner:nil options:nil] firstObject];
    }
    Exam *exam = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell configModel:exam];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 200;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Exam *exam = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"AnswerQuestion"];
    request.predicate = [NSPredicate predicateWithFormat:@"whoAnswerQuestion = %@ AND name = %@ AND semesterId = %@",exam.whoExam, exam.examName,exam.semesterId];
    NSArray *courseArray = [self.user.managedObjectContext executeFetchRequest:request error:nil];
    if ([courseArray count]) {
        AnswerQuestion *answerQuestion = [courseArray firstObject];
        //考试对应的答疑情况
        AnswerQeustionViewController *answerQusetionVCT = [[AnswerQeustionViewController alloc] init];
        answerQusetionVCT.answerQuestion = answerQuestion;
        [self.navigationController pushViewController:answerQusetionVCT animated:YES];
    }
}

#pragma - mark UITabBarController animated
-(void)viewWillDisappear:(BOOL)animated
{
    CATransition *transition = [CATransition animation];
    [transition setDuration:0.5f];
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromLeft;
    [self.tabBarController.view.layer addAnimation:transition forKey:nil];
}
@end
