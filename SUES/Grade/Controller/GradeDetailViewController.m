//
//  GradeDetailViewController.m
//  SUES
//
//  Created by lixu on 16/9/13.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import "GradeDetailViewController.h"
#import "AppDelegate.h"
#import "Public.h"
#import "User.h"
#import "Grade.h"
#import "PublicCell.h"

@interface GradeDetailViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,assign) CGFloat statusHeight;
@property (nonatomic,assign) CGFloat navHeight;
@property (nonatomic,assign) CGFloat tabBarHeight;
@property (nonatomic,strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,strong) User *user;
@end

@implementation GradeDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //获取当前状态栏的高度
    self.statusHeight = [[UIApplication sharedApplication]statusBarFrame].size.height;
    //获取导航栏的高度
    self.navHeight = self.navigationController.navigationBar.frame.size.height;
    //标签栏高度
    self.tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    
    self.managedObjectContext = self.user.managedObjectContext;
    self.tabBarItem.title = @"成绩";
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


-(void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    NSFetchRequest *gradeRequest = [NSFetchRequest fetchRequestWithEntityName:@"Grade"];
    gradeRequest.predicate = [NSPredicate predicateWithFormat:@"whoGrade = %@ AND yearAndSemester = %@", self.user,self.yearAndSemester];
    gradeRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                                                    ascending:NO
                                                                                                     selector:@selector(localizedStandardCompare:)]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:gradeRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"yearAndSemester" cacheName:nil];
    [self.tableView reloadData];
}

//创建分组的标题
-(NSString *)createTitleForHeader:(NSString *)baseTitle
{
    return baseTitle;
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
    Grade *grade = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell configModel:grade];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 200;
}
@end
