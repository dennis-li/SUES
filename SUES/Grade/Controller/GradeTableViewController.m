//
//  GradeTableViewController.m
//  SUES
//
//  Created by lixu on 16/8/18.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import "GradeTableViewController.h"
#import "Public.h"
#import "Grade.h"
#import "PublicCell.h"
#import "AppDelegate.h"
#import "MyDownloader.h"
#import "Networking.h"
#import "MBProgressHUD.h"

@interface GradeTableViewController ()
@property (nonatomic,assign) CGFloat statusHeight;
@property (nonatomic,assign) CGFloat navHeight;
@property (nonatomic,assign) CGFloat tabBarHeight;
@property (nonatomic,strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,strong) User *user;
@end

@implementation GradeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //获取当前状态栏的高度
    self.statusHeight = [[UIApplication sharedApplication]statusBarFrame].size.height;
    //获取导航栏的高度
    self.navHeight = self.navigationController.navigationBar.frame.size.height;
    //标签栏高度
    self.tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    
    [self createRefreshButton];
    self.managedObjectContext = self.user.managedObjectContext;
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
    [btn addTarget:self action:@selector(refreshGrade) forControlEvents:UIControlEventTouchUpInside];
    [btn setTintColor:[UIColor blackColor]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}

-(void)refreshGrade
{
    __weak GradeTableViewController *weakSelf = self;
    Networking *networking = [[Networking alloc] init];
    networking.requestFinish = ^(NSString *requestString,NSString *error){
        if (LX_DEBUG) {
            NSLog(@"refreshGrade: It's work!");
        }
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:weakSelf.navigationController.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.offset = CGPointMake(0.f, -0.f);
        [hud hideAnimated:YES afterDelay:0.8f];
        if (error) {
            hud.label.text = NSLocalizedString(error, @"HUD message title");
        }else {
            hud.label.text = NSLocalizedString(requestString, @"HUD message title");
        }
    };
    [networking refreshHtmlDataWithNetworkingType:RefreshGrade];
}

-(void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    NSFetchRequest *gradeRequest = [NSFetchRequest fetchRequestWithEntityName:@"Grade"];
    gradeRequest.predicate = [NSPredicate predicateWithFormat:@"whoGrade = %@", self.user];
    NSSortDescriptor *typeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"yearAndSemester" ascending:NO];
    NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:typeDescriptor, nameDescriptor, nil];
    [gradeRequest setSortDescriptors:sortDescriptors];
//    gradeRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"yearAndSemester"
//                                                              ascending:NO
//                                                               selector:@selector(localizedStandardCompare:)]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:gradeRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"yearAndSemester" cacheName:nil];
//    [self createDataSource];
    [self.tableView reloadData];
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
