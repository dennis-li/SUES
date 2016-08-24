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

@interface GradeTableViewController ()
@property (nonatomic,strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,strong) User *user;
@end

@implementation GradeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self observerNotification];
    // Do any additional setup after loading the view.
    self.managedObjectContext = self.user.managedObjectContext;
}

-(void)observerNotification
{
    
    [[NSNotificationCenter defaultCenter]
     addObserverForName:@"sendContextToForegroundTable"
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
    gradeRequest.predicate = [NSPredicate predicateWithFormat:@"whoGrade = %@", self.user];
    gradeRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"startSchoolYear"
                                                              ascending:NO
                                                               selector:@selector(localizedStandardCompare:)]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:gradeRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    [self createDataSource];
    [self.tableView reloadData];
}

-(User *)user
{
    if (!_user) {
        AppDelegate *app = [[UIApplication sharedApplication] delegate];
        _user = app.user;
    }
    return _user;
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
    NSArray *sectinArray = [self.dataDictionary objectForKey:[self.sectionName objectAtIndex:indexPath.section]];
    Grade *grade = [sectinArray objectAtIndex:indexPath.row];
    [cell configModel:grade];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 200;
}


@end
