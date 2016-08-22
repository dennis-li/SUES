//
//  AppDelegate.m
//  SUES
//
//  Created by lixu on 16/8/15.
//  Copyright © 2016年 lixu. All rights reserved.
//KEY

#import "AppDelegate.h"
#import "MainTabBarController.h"
#import "CreateContext.h"
#import "TFHpple.h"
#import "Public.h"
#import "Courses+Flickr.h"
#import "Grade+Flickr.h"
#import "User+Create.h"
#import <AFNetworking.h>

@interface AppDelegate ()<UIWebViewDelegate>
@property (readwrite, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,strong) UIWebView *weebView;
@property (nonatomic,strong) NSMutableArray *coursesArray;
@property (nonatomic,strong) NSMutableDictionary *userDictionary;
@end

@implementation AppDelegate
-(NSMutableDictionary *)userDictionary
{
    if (!_userDictionary) {
        _userDictionary = [[NSMutableDictionary alloc] init];
    }
    return _userDictionary;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    UIWebView *webView  = [[UIWebView alloc] init];
    webView.delegate = self;
    self.weebView = webView;
//    [self test];
    [self checkLogin];
    return YES;
}

-(void)test
{
    NSString *username = @"023113141";
    NSString *password = @"";
    //    NSString *username = self.usernameTF.text;
    //    NSString *password = self.passwordTF.text;
    
    NSString *capatcha = @"";
    NSString *gotoOnFaili = @"http://my.sues.edu.cn/loginFailure.portal";
    NSString *gotoSuccess = @"http://my.sues.edu.cn/loginSuccess.portal";
    
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
    [managers POST:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"请求成功，服务器返回的信息%@",responseObject);
        NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        NSLog(@"result = %@",result);
        if (![result containsString:@"handleLoginSuccessed"]) {
            NSLog(@"密码或用户名错误");
        } else{
            NSString *URLString = @"http://jxxt.sues.edu.cn/eams/courseTableForStd.action?method=courseTable&setting.forSemester=0&setting.kind=std&semester.id=402&ids=72123730&ignoreHead=1";
            NSURL *url = [NSURL URLWithString:URLString];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            [self.weebView loadRequest:request];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"需要链接学校的无线网error = %@",error);
    }];
}
//webView加载完成之后,把数据传到AppDelegate
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *string = [self.weebView stringByEvaluatingJavaScriptFromString: @"document.body.innerHTML"];
    NSLog(@"webViewHTML = %@",string);
}
-(void)checkLogin
{
    self.managedObjectContext = [CreateContext createContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    //    request.predicate = [NSPredicate predicateWithFormat:@"whoCourse = %@", self.user];
    NSArray *courseArray = [self.managedObjectContext executeFetchRequest:request error:nil];
    
    if (0) {
        self.user = [courseArray lastObject];
        [self.userDictionary setValue:self.user.name forKey:USER_NAME];
        [self.userDictionary setValue:self.user.password forKey:USER_PASSWORD];
        [self.userDictionary setValue:self.user.userId forKey:USER_ID];
        [self changeRootCtroller];
    }
}

-(void)changeRootCtroller
{
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:250.0f/255.0f green:210.0f/255.0f blue:40.0f/255.0f alpha:1.0f]];
    MainTabBarController *tabCtrl = [[MainTabBarController alloc] init];
//    self.window.rootViewController = tabCtrl;
    
    [UIView transitionWithView:[[UIApplication sharedApplication].delegate window]
                      duration:0.4
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        BOOL oldState=[UIView areAnimationsEnabled];
                        [UIView setAnimationsEnabled:NO];
                        [[[UIApplication sharedApplication].delegate window] setRootViewController:tabCtrl];
                        [UIView setAnimationsEnabled:oldState];
                        
                    }
                    completion:NULL];
}

//返回登录信息
-(void)startUserDataWithUserDetail:(NSString *)HTMLData userId:(NSString *)userId userPassWord:(NSString *)userPassWord
{
    [self.userDictionary setValue:userId  forKey:USER_ID];
    [self.userDictionary setValue:userPassWord forKey:USER_PASSWORD];
    [self startUserDataFetchWithHtmlData:HTMLData];
}

//开始获取用户的数据，并创建用户self.user
-(void)startUserDataFetchWithHtmlData:(NSString *)HTMLData
{
    
    NSData *htmlData= [HTMLData dataUsingEncoding:NSUTF8StringEncoding];
    
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
    if (!self.user) {
            NSArray *userNameArray = [xpathParser searchWithXPathQuery:@"//table[@id='myBar']/tbody/tr/td[2]/b"];
            TFHppleElement *element = [userNameArray firstObject];
            NSString *userName = [[[element content] componentsSeparatedByString:@":"] lastObject];
            [self.userDictionary setValue:userName forKey:USER_NAME];
            self.user = [User userWithName:self.userDictionary inManagedObjectContext:self.managedObjectContext];
    }
    NSArray *elements  = [xpathParser searchWithXPathQuery:@"//table[@class='listTable']/tbody/tr[position()>2]/td"];
    if ([elements count]) {
        if (LX_DEBUG) {
            NSLog(@"[%@->%@] requestData",NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        }
    }
    [self saveDownloadData:elements];
}


-(void)saveDownloadData :(NSArray *)elements
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
#warning -暂用period做为课程唯一标识符
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
    [self sendNotificationToCourseTable];
}

-(void)sendNotificationToCourseTable
{
    NSDictionary *userInfo = @{@"context" : self.managedObjectContext};
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"sendContextToCourseTable"
     object:self
     userInfo:userInfo];
}

//返回一个字典，存储课程详情
-(NSMutableDictionary *)createACourseDictionary
{
    return [[NSMutableDictionary alloc] init];
}

//存储所有的课程信息
-(NSMutableArray *)coursesArray
{
    if (!_coursesArray) {
        _coursesArray = [[NSMutableArray alloc] init];
    }
    return _coursesArray;
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

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    
}



//- (NSManagedObjectContext *)managedObjectContext {
//    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
//    if (_managedObjectContext != nil) {
//        return _managedObjectContext;
//    }
//    
//    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
//    if (!coordinator) {
//        return nil;
//    }
//    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
//    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
//    return _managedObjectContext;
//}



@end
