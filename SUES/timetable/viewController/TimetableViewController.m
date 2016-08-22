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


@interface TimetableViewController ()<UIWebViewDelegate,UpdateUserViewDelegate>

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
    weekView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:weekView];
    self.weekView = weekView;
    weekView.ctrl = self;
    weekView.currentWeek = @"1";
    
    UpdateUserView *updateUserView = [[UpdateUserView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    self.signInView = updateUserView;
    updateUserView.delegate = self;
    [self checkSignIn];
    
    [self createNextWeekButton];
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 567, 375,100)];
    self.webView = webView;
    self.webView.delegate = self;
    webView.scalesPageToFit = NO;
    
    /*
    
    self.swipeView = [[SwipeView alloc] initWithFrame:CGRectMake(0, statusRect.size.height+navRect.size.height, self.view.frame.size.width, self.view.frame.size.height-(statusRect.size.height+navRect.size.height+tabBarRect.size.height))];
    self.swipeView.pagingEnabled = YES;
    self.swipeView.delegate = self;
    self.swipeView.dataSource = self;
     */
}

-(void)checkSignIn
{
    self.managedObjectContext = [CreateContext createContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
//    request.predicate = [NSPredicate predicateWithFormat:@"whoCourse = %@", self.user];
    NSArray *courseArray = [self.managedObjectContext executeFetchRequest:request error:nil];
    User *user = [courseArray firstObject];
    if (user) {
        self.user = user;
        self.weekView.user = user;
    } else {
        self.navigationController.navigationBar.hidden = YES;
        self.tabBarController.tabBar.hidden = YES;
        [self.view addSubview:self.signInView];
    }
}

-(void)signFinish:(NSString *)userName pass:(NSString *)password
{
    self.navigationController.navigationBar.hidden = NO;
    self.tabBarController.tabBar.hidden = NO;
    [self.signInView removeFromSuperview];
    self.userPassWord = password;
    self.userId = userName;
    NSString *URLString = @"http://jxxt.sues.edu.cn/eams/courseTableForStd.action?method=courseTable&setting.forSemester=0&setting.kind=std&semester.id=402&ids=72123730&ignoreHead=1";
    self.urlString = URLString;
}

-(void)createNextWeekButton
{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 40)];
    [btn setTitle:@"下一周" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    [btn setTintColor:[UIColor blackColor]];
    self.navigationItem.titleView = btn;
}

-(void)click
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

-(NSMutableArray *)coursesArray
{
    if (!_coursesArray) {
        _coursesArray = [[NSMutableArray alloc] init];
    }
    return _coursesArray;
}

-(void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
//    NSMutableDictionary *userDictionary = [[NSMutableDictionary alloc] init];
//    [userDictionary setValue:@"李旭" forKey:USER_NAME];
//    [userDictionary setValue:@"1234" forKey:USER_PASSWORD];
//    [userDictionary setValue:@"023113141" forKey:USER_ID];
//    self.userDictionary = userDictionary;
//    self.user = [User userWithName:userDictionary inManagedObjectContext:self.managedObjectContext];
}


#pragma -mark 下载数据
-(void)downloadData:(NSArray *)elements
{
    //存储一个课程
    NSMutableDictionary *courseDictionary = nil;//新建一个课程字典
    NSString *week;
    NSInteger whichLesson = 0;
    NSInteger sectionStart = 0;
    NSInteger sectionEnd = 0;
    for (TFHppleElement *element in elements) {
        whichLesson++;
        if ([[element objectForKey:@"class"] isEqualToString:@"darkColumn"]) {//匹配星期几
            week = [element content];
            whichLesson = 0;
        }
        
        if ([element objectForKey:@"colspan"]) {
            sectionEnd = [[element objectForKey:@"colspan"] integerValue]+whichLesson-1;
            sectionStart = whichLesson;
            whichLesson = sectionEnd;
        }
        
        //找到一个课程详情
        if ([[element objectForKey:@"class"] isEqualToString:@"infoTitle"]) {
            NSString *course = [element objectForKey:@"title"];
            if (!course) {
                if (LX_DEBUG) {
                    NSLog(@"[%@->%@] flickr Course",NSStringFromClass([self class]), NSStringFromSelector(_cmd));
                }
                continue;
            }
            
            /*@[王国强 多元微积分A（上）(0014), (1-8,B310多), 沈军 多元微积分A（下）(4477), (10-17,A307多)*/
            NSArray *courseArray = [course componentsSeparatedByString:@";"];
            if (![courseArray count]) {
                continue;
            }
            for (NSString *courseDetail in courseArray) {
                if (![[courseDetail substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"("]) {
                    if (courseDictionary) {
                        if (LX_DEBUG) {
                            for (NSString *string in courseDictionary) {
                                NSLog(@"%@ = %@",string,courseDictionary[string]);
                            }
                            NSLog(@"-----------------------------------");
                        }
                        
                    }
                    courseDictionary = [self createACourseDictionary];
                    [self.coursesArray addObject:courseDictionary];
                    [courseDictionary setValue:[NSNumber numberWithInteger:sectionStart] forKey:COURSE_SECTIONSTART];
                    [courseDictionary setValue:[NSNumber numberWithInteger:sectionEnd] forKey:COURSE_SECTIONEND];
                    [courseDictionary setValue:[NSNumber numberWithInteger:2015] forKey:COURSE_STARTSCHOOLYEAR];
                    [courseDictionary setValue:[NSNumber numberWithInteger:2] forKey:COURSE_SEMESTER];
                    [courseDictionary setValue:self.userDictionary forKey:COURSE_WHOCOURSE];
                    
                    NSArray *teacherAndcourseNameArray = [courseDetail componentsSeparatedByString:@" "];
                    if ([teacherAndcourseNameArray count] > 1) {
                        for (NSString *teacher in teacherAndcourseNameArray) {
                            NSLog(@"teacher = %@",teacher);
                        }
                        [courseDictionary setValue:[teacherAndcourseNameArray firstObject] forKey:COURSE_TEACHER];//老师
                    } else {
                        [courseDictionary setValue:@"待定" forKey:COURSE_TEACHER];
                    }
                    
                    NSArray *courseNameAndIdArray = [[teacherAndcourseNameArray lastObject] componentsSeparatedByString:@"("];//高歌 电路(一)(3911);(1-8,C110多); 制造技术基础实习C(3897);(10-11,实训楼1号楼底楼7号门大厅)
                    [courseDictionary setValue:[courseNameAndIdArray firstObject] forKey:COURSE_NAME];
                    
                    NSString *courseId = [[courseNameAndIdArray lastObject] substringToIndex:[[courseNameAndIdArray lastObject]length]-1];
                    [courseDictionary setValue:courseId forKey:COURSE_ID];
#warning -咱用period做为课程唯一标识符
                    NSString *period = [[[self weekToDay:week] stringByAppendingString:[NSString stringWithFormat:@"%ld",sectionStart]] stringByAppendingString:courseId];
                    [courseDictionary setValue:period forKey:COURSE_PERIOD];
                } else {
                    
                    if ([courseDictionary objectForKey:COURSE_DAY]) {
                        //这种情况－－高燕 自动控制理论A(0524);(11,训1104-1111);(12-14,训1105);(1-8 10,D302多)
                        NSString *oldLocale = [courseDictionary objectForKey:COURSE_LOCALE];
                        NSString *oldSmartPeriod = [courseDictionary objectForKey:COURSE_SMARTPERIOD];
                        
                        NSArray *courseTimeAndLocaleArray = [courseDetail componentsSeparatedByString:@","];
                        //上课时间
                        NSString *courseTime = [[courseTimeAndLocaleArray firstObject] substringFromIndex:1];//4 8 双12-14
                        NSString *smartPeriod = [self returnTotalSmartData:courseTime];
                        
                        [courseDictionary setValue:[oldLocale stringByAppendingString:[NSString stringWithFormat:@",%@",courseDetail]] forKey:COURSE_LOCALE];//上课地点
                        [courseDictionary setValue:[oldSmartPeriod stringByAppendingString:smartPeriod] forKey:COURSE_SMARTPERIOD];
                    } else {//这里只运行一次
                        
                        [courseDictionary setValue:[NSNumber numberWithInteger:[[self weekToDay:week] integerValue]] forKey:COURSE_DAY];
                        NSArray *courseTimeAndLocaleArray = [courseDetail componentsSeparatedByString:@","];
                        
                        //上课时间
                        NSString *courseTime = [[courseTimeAndLocaleArray firstObject] substringFromIndex:1];//4 8 双12-14
                        NSString *smartPeriod = [self returnTotalSmartData:courseTime];
                        
                        [courseDictionary setValue:courseDetail forKey:COURSE_LOCALE];//上课地点
                        [courseDictionary setValue:smartPeriod forKey:COURSE_SMARTPERIOD];
                    }
                }
            }
        }
    }
    [Courses loadCourseFromFlickrArray:self.coursesArray intoManagedObjectContext:self.managedObjectContext];
    [self.managedObjectContext save:NULL];
    self.weekView.user = self.user;
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.user = self.user;
    NSLog(@"app.user.name = %@",appDelegate.user.name);
}



-(NSString *)weekToDay:(NSString *)week
{
    if ([week isEqualToString:@"星期一"]) {
        return @"1";
    } else if([week isEqualToString:@"星期二"]){
        return @"2";
    } else if([week isEqualToString:@"星期三"]){
        return @"3";
    } else if([week isEqualToString:@"星期四"]){
        return @"4";
    } else if([week isEqualToString:@"星期五"]){
        return @"5";
    } else if([week isEqualToString:@"星期六"]){
        return @"6";
    } else if([week isEqualToString:@"星期日"]){
        return @"7";
    }
    return @"0";
}

//网络请求
-(void)newWrokResquest
{
    NSString *username = @"023113141";
    NSString *password = @"";
    NSString *capatcha = @"";
    NSString *gotoOnFaili = @"http://my.sues.edu.cn/loginFailure.portal";
    NSString *gotoSuccess = @"http://my.sues.edu.cn/loginSuccess.portal";
    //请求的参数
    
    NSDictionary *parameters = @{@"Login.Token1":username,
                                 @"Login.Token2":password,
                                 @"capatcha":capatcha,
                                 @"goto":gotoSuccess,
                                 @"gotoOnFaili":gotoOnFaili
                                 };
    //请求的url
    NSString *urlString = @"http://my.sues.edu.cn/userPasswordValidate.portal";
    //请求的managers
    AFHTTPSessionManager *managers = [AFHTTPSessionManager manager];
    //请求的方式：POST
    managers.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    managers.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [managers POST:urlString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"服务器请求成功");
        NSLog(@"Result = %@",result);
        
        
       
        
    } failure:^(NSURLSessionDataTask *task, NSError * error) {
        NSLog(@"请求失败,服务器返回的错误信息%@",error);
    }];
    
}

-(void)setUrlString:(NSString *)urlString
{
    NSLog(@"setUrlString = %@",urlString);
    //请求数据
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *string = [self.webView stringByEvaluatingJavaScriptFromString: @"document.body.innerHTML"];
    NSLog(@"webViewHTML = %@",string);
    [self netWorkResult:string];
}

//解析html
-(void)netWorkResult:(NSString *)htmlString
{
    
    NSData *htmlData= [htmlString dataUsingEncoding:NSUTF8StringEncoding];
    
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
    //[userDictionary setValue:@"李旭" forKey:USER_NAME];
    NSArray *userNameArray = [xpathParser searchWithXPathQuery:@"//table[@id='myBar']/tbody/tr/td[2]/b"];
    TFHppleElement *element = [userNameArray firstObject];
    NSString *userName = [[[element content] componentsSeparatedByString:@":"] lastObject];
    NSMutableDictionary *userDictionary = [[NSMutableDictionary alloc] init];
    [userDictionary setValue:userName forKey:USER_NAME];
    [userDictionary setValue:self.userPassWord forKey:USER_PASSWORD];
    [userDictionary setValue:self.userId forKey:USER_ID];
    self.userDictionary = userDictionary;
    self.user = [User userWithName:userDictionary inManagedObjectContext:self.managedObjectContext];
    NSArray *elements  = [xpathParser searchWithXPathQuery:@"//table[@class='listTable']/tbody/tr[position()>2]/td"];
    if ([elements count]) {
        if (LX_DEBUG) {
            NSLog(@"[%@->%@] requestData",NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        }
    }
    [self downloadData:elements];
}

//返回一个字典，存储课程详情
-(NSMutableDictionary *)createACourseDictionary
{
    return [[NSMutableDictionary alloc] init];
}

//给定一个上课时间字符串，返回总共的具体上课时间smartPeriod = 10 11 12 13 14 15 16 17
-(NSString *)returnTotalSmartData:(NSString *)courseTime
{
    NSArray *courseTimes = [courseTime componentsSeparatedByString:@" "];//@[4, 8, 双12-14]
    NSMutableString *smartPeriod = [[NSMutableString alloc] init];
    for (NSString *coursetime in courseTimes) {
        if ([coursetime length] < 3) {
            [smartPeriod appendString:[NSString stringWithFormat:@"%@ ",coursetime]];
        }else {
            NSString *temp = [coursetime substringWithRange:NSMakeRange(0, 1)];
            if ([temp isEqualToString:@"单"] || [temp isEqualToString:@"双"]) {
                NSArray *times = [[coursetime substringFromIndex:1] componentsSeparatedByString:@"-"];
                [smartPeriod appendString:[self returnSmartValue:2 startNum:[times firstObject] endNum:[times lastObject]]];
            } else {
                NSArray *times = [coursetime componentsSeparatedByString:@"-"];
                [smartPeriod appendString:[self returnSmartValue:1 startNum:[times firstObject] endNum:[times lastObject]]];
            }
        }
    }
    return smartPeriod;
}
//给定一个上课时间范围，返回具体的上课时间
-(NSString *)returnSmartValue:(NSInteger)step startNum:(NSString *)startNum endNum:(NSString *)endNum
{
    NSMutableString *string = [[NSMutableString alloc] init];
    NSInteger start,end;
    start = [startNum integerValue];
    end = [endNum integerValue];
    for (; start <= end; start+=step) {
        [string appendString:[NSString stringWithFormat:@"%ld ",start]];
    }
    return string;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





@end
