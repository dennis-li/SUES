//
//  GradeTableViewController.m
//  SUES
//
//  Created by lixu on 16/8/18.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import "GradeTableViewController.h"
#import "TFHpple.h"
#import <AFNetworking.h>
#import "Public.h"
#import "Grade.h"
#import "Grade+Flickr.h"
#import "PublicCell.h"
#import "CreateContext.h"
#import "AppDelegate.h"

@interface GradeTableViewController ()
@property (nonatomic,strong) NSMutableArray *gradeArray;
@property (nonatomic,strong) NSMutableDictionary *userDictionary;
@end

@implementation GradeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.managedObjectContext = [CreateContext createContext];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSLog(@"user.name = %@",appDelegate.user.name);
    NSLog(@"viewLoad");
}

-(void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    
    NSFetchRequest *userRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    userRequest.predicate = nil;
    NSArray *userArray = [self.managedObjectContext executeFetchRequest:userRequest error:nil];
    self.user = [userArray lastObject];
    NSLog(@"user.Name = %@",self.user.name);
    
    NSFetchRequest *gradeRequest = [NSFetchRequest fetchRequestWithEntityName:@"Grade"];
    gradeRequest.predicate = [NSPredicate predicateWithFormat:@"whoGrade = %@", self.user];
    gradeRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                              ascending:YES
                                                               selector:@selector(localizedStandardCompare:)]];
    NSArray *gradeArray = [self.managedObjectContext executeFetchRequest:gradeRequest error:nil];
    if ([gradeArray count]) {
//        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Grade"];
//        request.predicate = [NSPredicate predicateWithFormat:@"whoGrade = %@", self.user];
//        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name"
//                                                                  ascending:YES
//                                                                   selector:@selector(localizedStandardCompare:)]];
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:gradeRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        [self createDataSource];
    } else {
        [self requesHTMLData];
    }
    
//    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Grade"];
//    request.predicate = [NSPredicate predicateWithFormat:@"whoGrade = %@", self.user];
//    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name"
//                                                              ascending:YES
//                                                               selector:@selector(localizedStandardCompare:)]];
//    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
//    [self createDataSource];
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



#pragma -mark 下载成绩

-(NSMutableArray *)gradeArray
{
    if (!_gradeArray) {
        _gradeArray = [[NSMutableArray alloc] init];
    }
    return _gradeArray;
}

-(void)downloadGradeData:(NSArray *)gradeData
{
    NSMutableDictionary *gradeCourseDictionary;
    
//    NSMutableDictionary *userDictrionary = [[NSMutableDictionary alloc] init];
//    [userDictrionary setValue:@"李旭" forKey:USER_NAME];
//    [userDictrionary setValue:@"1234" forKey:USER_PASSWORD];
//    [userDictrionary setValue:@"023113141" forKey:USER_ID];
//    self.userDictionary = userDictrionary;
//    self.user = [User userWithName:userDictrionary inManagedObjectContext:self.managedObjectContext];
    
    NSInteger key = 0;
    for (TFHppleElement *element in gradeData) {
        if (!(key % 11)) {
    
            gradeCourseDictionary = [self createACourseDictionary];
            [self.gradeArray addObject:gradeCourseDictionary];
//            [gradeCourseDictionary setValue:[NSNumber numberWithInteger:2] forKey:COURSE_SEMESTER];
//            [gradeCourseDictionary setValue:[NSNumber numberWithInteger:2015] forKey:COURSE_STARTSCHOOLYEAR];
            [gradeCourseDictionary setValue:self.user.userId forKey:GRADE_WHOGRADE];
        }
        switch (key % 11) {
            case 0:
                [gradeCourseDictionary setValue:[[element content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:COURSE_CODE];
                break;
            case 1:
                [gradeCourseDictionary setValue:[[element content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:COURSE_ID];
                break;
            case 2:
                [gradeCourseDictionary setValue:[[element content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:COURSE_NAME];
                break;
            case 3:
                [gradeCourseDictionary setValue:[[element content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:GRADE_CATEGORY];
                break;
            case 4:
                [gradeCourseDictionary setValue:[[element content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:GRADE_CREDIT];
                break;
            case 5:
                [gradeCourseDictionary setValue:[[element content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:GRADE_MIDTERMGRADE];
                break;
            case 6:
                [gradeCourseDictionary setValue:[[element content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:GRADE_FINALGRADE];
                break;
            case 7:
                [gradeCourseDictionary setValue:[[element content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:GRADE_MAKEUPEXAMGRADE];
                break;
            case 8:
                [gradeCourseDictionary setValue:[[element content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:GRADE_FINALGRADE];
                break;
            case 9:
                [gradeCourseDictionary setValue:[[element content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:GRADE_GRADEPOINT];
                break;
            case 10:
            {
                NSArray *semesterAndYear =  [[element content] componentsSeparatedByString:@" "];
                NSString *year = [[[semesterAndYear firstObject] componentsSeparatedByString:@"-"] firstObject];
                [gradeCourseDictionary setValue:[NSNumber numberWithInteger:[year integerValue]] forKey:COURSE_STARTSCHOOLYEAR];
                [gradeCourseDictionary setValue:[NSNumber numberWithInteger:[[semesterAndYear lastObject] integerValue]] forKey:COURSE_SEMESTER];
            }
                break;
            default:
                break;
        }
        
        key++;
    }
    [Grade loadGradeFromFlickrArray:self.gradeArray intoManagedObjectContext:self.managedObjectContext];
    
    [self.managedObjectContext save:NULL];
    [self fetchData];
}

-(void)fetchData
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Grade"];
    request.predicate = [NSPredicate predicateWithFormat:@"whoGrade = %@", self.user];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                              ascending:YES
                                                               selector:@selector(localizedStandardCompare:)]];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    [self createDataSource];
}

//网络请求
-(void)netWorkRequest:(NSData *)htmlData
{
//    NSString *htmlPath = [[NSBundle mainBundle]pathForResource:@"totalGrade" ofType:@"html"];
    
//    NSData *htmlData= [NSData dataWithContentsOfFile:htmlPath];
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
    NSArray *elements  = [xpathParser searchWithXPathQuery:@"//table[@id='gradeTable']/tr[position()>1]/td"];
//    for (TFHppleElement *element in elements) {
//        NSLog(@"--%@",[[element content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]);
//    }
    if ([elements count]) {
        if (LX_DEBUG) {
            NSLog(@"[%@->%@] requestData",NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        }
    }
    [self downloadGradeData:elements];
}

-(void)requesHTMLData
{
    
    NSString *URLString = @"http://jxxt.sues.edu.cn/eams/personGrade.action?method=historyCourseGrade";
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:URLString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"resutl..grade = %@",result);
        [self netWorkRequest:[result dataUsingEncoding:NSUTF8StringEncoding]];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error = %@",error);
    }];
}

//返回一个字典，存储课程详情
-(NSMutableDictionary *)createACourseDictionary
{
    return [[NSMutableDictionary alloc] init];
}

/***
 *数据库的操作核心
 *类比于搜狐项目的DBmanager
 */
#pragma mark - Core Data
/*
- (void)saveContext:(NSManagedObjectContext *)managedObjectContext
{
    NSError *error = nil;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            //这个实现替换为适当的代码来处理错误。
            /// abort()会导致应用程序生成一个崩溃日志和终止。你不应该使用这个函数在船舶应用程序中,虽然它可能是有用的在开发过程中。
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (NSManagedObjectContext *)createMainQueueManagedObjectContext
{
    NSManagedObjectContext *managedObjectContext = nil;
    NSPersistentStoreCoordinator *coordinator = [self createPersistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext;
}


//返回应用程序的托管对象模型。
//如果模型不存在,它从应用程序的创建模型。
- (NSManagedObjectModel *)createManagedObjectModel
{
    NSManagedObjectModel *managedObjectModel = nil;
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"SUES" withExtension:@"momd"];
    managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return managedObjectModel;
}


//返回应用程序的持久性存储协调员。
//如果协调不存在,这是创建和应用程序的商店添加到它。
- (NSPersistentStoreCoordinator *)createPersistentStoreCoordinator
{
    NSPersistentStoreCoordinator *persistentStoreCoordinator = nil;
    NSManagedObjectModel *managedObjectModel = [self createManagedObjectModel];
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"SUES.sqlite"];
    
    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return persistentStoreCoordinator;
}

//返回应用程序的文档目录的URL

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

*/
@end
