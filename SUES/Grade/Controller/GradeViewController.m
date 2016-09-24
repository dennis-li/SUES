//
//  GradeViewController.m
//  SUES
//
//  Created by lixu on 16/9/9.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import "GradeViewController.h"
#import "GradeDetailViewController.h"
#import "Public.h"
#import "User.h"
#import "Grade.h"

@interface GradeViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic ,strong) UITableView *tbView;

@property (nonatomic ,strong) NSArray *sectionArray;//存放所有学年，作为分组依据
@property (nonatomic ,strong) NSMutableDictionary *yearAndSemesterDictionary;//存放所有学年的学期数组
@property (nonatomic ,strong) NSDictionary *dataDictionary;//存放学期对应的所有@[grade]，即每个value是一个数组

@end

@implementation GradeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNavTitle:@"成绩"];
    [self createDataArray];
    [self createTableView];
}

-(void)createTableView
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UITableView *tbView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.statusHeight+self.navHeight, ScreenWidth, ScreenHeight-self.statusHeight-self.navHeight-self.tabBarHeight) style:UITableViewStylePlain];
    tbView.delegate = self;
    tbView.dataSource = self;
    self.tbView = tbView;
    [self.view addSubview:tbView];
}

#pragma  - mark UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *year = [self.sectionArray objectAtIndex:section];
    NSArray *yearAndSemesterArray = [NSArray arrayWithArray:[[self.yearAndSemesterDictionary objectForKey:year] allObjects]];
    [self.yearAndSemesterDictionary setObject:yearAndSemesterArray forKey:year];
    return [yearAndSemesterArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    NSString *year = [self.sectionArray objectAtIndex:indexPath.section];
    NSArray *yearAndSemesterArray = [self.yearAndSemesterDictionary objectForKey:year];
    cell.textLabel.text = yearAndSemesterArray[indexPath.row];
    NSString *semester = [[cell.textLabel.text componentsSeparatedByString:@" "] lastObject];
    NSString *imageName = [semester isEqualToString:@"1"] ? @"number1" :@"number2";
    cell.imageView.image = [UIImage imageNamed:imageName];
    
    //调整图片大小
    CGSize itemSize = CGSizeMake(cell.frame.size.height/2, cell.frame.size.height/2);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [cell.imageView.image drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sectionArray count];
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    GradeDetailViewController *gradeCtrl = [[GradeDetailViewController alloc] init];
    gradeCtrl.yearAndSemester = cell.textLabel.text;
    gradeCtrl.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:gradeCtrl animated:YES];
}

#pragma - mark 创建数据源
-(void)createDataArray
{
    NSFetchRequest *gradeRequest = [NSFetchRequest fetchRequestWithEntityName:@"Grade"];
    gradeRequest.predicate = [NSPredicate predicateWithFormat:@"whoGrade = %@", self.user];
    gradeRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"yearAndSemester"
                                                                   ascending:YES
                                                                    selector:@selector(localizedStandardCompare:)]];
    NSArray *gradeArray = [self.user.managedObjectContext executeFetchRequest:gradeRequest error:nil];
    
    /*数据源
     *dataYearSet = @[2013,2015....];
     *yearAndSemesterDictionary = @{2013 : @[@"2013-1014 1",@"2013-1014 2"],....};
     *dataDictionary = @{2013-1014 1 : @[grade,grade....]};
     */
    NSMutableDictionary *dataDictionary = [[NSMutableDictionary alloc] init];//按学期存放grade数据
    NSMutableDictionary *yearAndSemesterDictionary = [[NSMutableDictionary alloc] init];//按学年存放学期数组（最多两个学期）
    NSMutableSet *dataYearSet = [[NSMutableSet alloc] init];//存放所有的学年
   
    for (Grade *grade in gradeArray) {
         NSMutableSet *dataYearAndSemesterSet = nil;//存放学年对应所有的学期
        [dataYearSet addObject:[grade.startSchoolYear stringValue]];
        if ((dataYearAndSemesterSet = [yearAndSemesterDictionary objectForKey:[grade.startSchoolYear stringValue]])) {
            //找到一个已有的学年，把学期字符串存进去
            [dataYearAndSemesterSet addObject:grade.yearAndSemester];
        } else {
            //找到一个新的学年，
            dataYearAndSemesterSet = [[NSMutableSet alloc] init];
            [dataYearAndSemesterSet addObject:grade.yearAndSemester];
            [yearAndSemesterDictionary setObject:dataYearAndSemesterSet forKey:[grade.startSchoolYear stringValue]];
        }
        
        NSMutableArray *dataArray = nil;
        if ((dataArray = [dataDictionary objectForKey:grade.yearAndSemester])) {
            //找到一个已有学期，把grade存进数组
            [dataArray addObject:grade];
        } else {
            //找到一个新的学期
            dataArray = [[NSMutableArray alloc] init];
            [dataArray addObject:grade];
            [dataDictionary setObject:dataArray forKey:grade.yearAndSemester];
        }
    }
    self.sectionArray = [dataYearSet allObjects];
    for (NSString *year in self.sectionArray) {
        NSLog(@"year = %@",year);
    }
    self.yearAndSemesterDictionary = yearAndSemesterDictionary;
    self.dataDictionary = dataDictionary;
}

@end
