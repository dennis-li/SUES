//
//  MyDownloader.m
//  SohuByObject_C
//
//  Created by lixu on 16/4/25.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import "MyDownloader.h"
#import "TFHpple.h"
#import "Public.h"
#import <UIKit/UIKit.h>
#import "User+Create.h"
#import "Courses+Flickr.h"
#import "AppDelegate.h"


@interface MyDownloader ()<UIWebViewDelegate>
@property (nonatomic ,strong)NSMutableDictionary *userDictionary;//存放user的信息
@property (nonatomic ,strong)NSMutableArray *coursesArray;//存放所有课程
@property (nonatomic ,strong)UIWebView *webView;//加载课表，加载完之后获取源码
@property (nonatomic ,strong)NSString *urlString;//需要加载内容的URL
@property (nonatomic ,strong)User *user;
@property (nonatomic ,strong)NSManagedObjectContext *managedObjectContext;
@end

@implementation MyDownloader

-(instancetype)init
{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter]
         addObserverForName:@"WeekViewToCourseDVC"
         object:nil
         queue:nil
         usingBlock:^(NSNotification * _Nonnull note) {
             self.userDictionary = note.userInfo[@"userDictionary"];
         }];
        self.webView = [[UIWebView alloc] init];
        self.webView.delegate = self;
    }
    return self;
}

-(NSManagedObjectContext *)managedObjectContext
{
    if (!_managedObjectContext) {
        _managedObjectContext = [self returnApp].managedObjectContext;
    }
    return _managedObjectContext;
}

-(User *)user
{
    if (!_user) {
        _user = [self returnApp].user;
    }
    return _user;
}

-(AppDelegate *)returnApp
{
    return [[UIApplication sharedApplication] delegate];
}

-(NSMutableDictionary *)userDictionary
{
    if (!_userDictionary) {
        _userDictionary = [[NSMutableDictionary alloc] init];
    }
    return _userDictionary;
}

-(NSMutableArray *)coursesArray
{
    if (!_coursesArray) {
        _coursesArray = [[NSMutableArray alloc] init];
    }
    return _coursesArray;
}

//第一次登录，需要下载所有数据
-(void)downloadWithUrlString:(NSString *)urlString downloadType:(DownloadType)type
                    userId:(NSString *)userId userPassWord:(NSString *)userPassWord
{
    self.urlString = urlString;
    [self.userDictionary setValue:userId  forKey:USER_ID];
    [self.userDictionary setValue:userPassWord forKey:USER_PASSWORD];
    [self loadWebView];
}

-(void)loadWebView
{
    NSURL *url = [NSURL URLWithString:self.urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
   
    NSString *string = [self.webView stringByEvaluatingJavaScriptFromString: @"document.body.innerHTML"];
    NSLog(@"webViewHTML = %@",string);
    [self startUserDataFetchWithHtmlData:string];
}

#pragma - mark Coursetable
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
        AppDelegate *app = [self returnApp];
        app.user = [User userWithName:self.userDictionary inManagedObjectContext:self.managedObjectContext];
    }
    NSArray *elements  = [xpathParser searchWithXPathQuery:@"//table[@class='listTable']/tbody/tr[position()>2]/td"];
    if ([elements count]) {
        if (LX_DEBUG) {
            NSLog(@"[%@->%@] requestData",NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        }
    }
    [self saveDownloadData:elements];
}

-(void)saveDownloadData:(NSArray *)elements
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
    [self sendNotificationToCourseTable];
    [self.delegate downloadFinish:self];
}

//处理完数据发送通知到前台
-(void)sendNotificationToCourseTable
{
    NSDictionary *userInfo = @{@"context" : self.managedObjectContext};
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"sendContextToCourseTable"
     object:self
     userInfo:userInfo];
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

@end
