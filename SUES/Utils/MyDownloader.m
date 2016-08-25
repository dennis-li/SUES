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
#import "User+Create.h"
#import "Courses+Flickr.h"
#import "Grade+Flickr.h"
#import "AppDelegate.h"


@interface MyDownloader ()
@property (nonatomic ,strong) NSMutableArray *gradeArray;//存放所有的成绩
@property (nonatomic ,strong) NSMutableDictionary *userDictionary;//存放user的信息
@property (nonatomic ,strong) NSMutableArray *coursesArray;//存放所有课程
@property (nonatomic ,strong) User *user;
@property (nonatomic ,strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic ,strong) NSMutableDictionary *courseDictionary;//存放一个课程详情
@property (nonatomic ,assign) NSInteger sectionStart;//从第几节开始上课
@property (nonatomic ,assign) NSInteger sectionEnd;
@property (nonatomic ,strong) NSString *week;//课程的Day，那天上课
@end

@implementation MyDownloader

-(instancetype)init
{
    if (self = [super init]) {
    
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

-(NSMutableDictionary *)courseDictionary
{
    if (!_courseDictionary) {
        _courseDictionary = [[NSMutableDictionary alloc] init];
    }
    return _courseDictionary;
}

-(NSMutableDictionary *)userDictionary
{
    if (!_userDictionary) {
        _userDictionary = [[NSMutableDictionary alloc] init];
    }
    return _userDictionary;
}

-(NSMutableArray *)gradeArray
{
    if (!_gradeArray) {
        _gradeArray = [[NSMutableArray alloc ] init];
    }
    return _gradeArray;
}

-(NSMutableArray *)coursesArray
{
    if (!_coursesArray) {
        _coursesArray = [[NSMutableArray alloc] init];
    }
    return _coursesArray;
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

-(void)sendNotificationToGradeTable
{
    NSDictionary *userInfo = @{@"context" : self.managedObjectContext};
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"sendContextToGradeTable"
     object:self
     userInfo:userInfo];
}

//登录的时候，请求所有用户数据
-(void)loginAnalyzeUserWithGradeHtmlData:(NSData *)htmlData userId:(NSString *)userId password:(NSString *)userPassword
{
    [self.userDictionary setValue:userId  forKey:USER_ID];
    [self.userDictionary setValue:userPassword forKey:USER_PASSWORD];
    [self analyzeGradeHtmlData:htmlData];
}

#pragma - mark Gradetable

-(void)analyzeGradeHtmlData:(NSData *)htmlData
{
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
    NSArray *elements  = [xpathParser searchWithXPathQuery:@"//table[@id='gradeTable']/tr[position()>1]/td"];
    
    if (!self.user) {//第一次登录，保存用户
        NSArray *userNameArray = [xpathParser searchWithXPathQuery:@"//div[@align='center']"];
        NSString *userName = nil;
        for (TFHppleElement *element in userNameArray) {
            if ([[element content] containsString:[self.userDictionary valueForKey:USER_ID]]) {
                NSArray *userNameDetail = [[element content] componentsSeparatedByString:@" "];
                if ([userNameDetail count] > 2) {
                    userName = [[[userNameDetail objectAtIndex:2] componentsSeparatedByString:@":"] lastObject];
                    if (LX_DEBUG) {
                        NSLog(@"%@--%@--userName = %@",NSStringFromClass([self class]), NSStringFromSelector(_cmd),userName);
                    }
                } else {
                    userName = @"无名";
                }
            }
        }
        [self.userDictionary setValue:userName forKey:USER_NAME];
        AppDelegate *app = [self returnApp];
        app.user = [User userWithName:self.userDictionary inManagedObjectContext:self.managedObjectContext];
        /*
         <table id="gradeBar"></table>
         <div align="center">Student No:0231 Name:李 Department:电子电气工程学院 Major:电气工程及其自动化 Major Field:无</div>
         */
    }
   
    if (![elements count]) {
        if (LX_DEBUG) {
            NSLog(@"[%@->%@] requestGradeData",NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        }
    }
    [self saveGradeData:elements];
}


-(void)saveGradeData:(NSArray *)gradeData
{
    NSMutableDictionary *gradeCourseDictionary;
    NSInteger key = 0;
    for (TFHppleElement *element in gradeData) {
        if (!(key % 11)) {
            gradeCourseDictionary = [self createACourseDictionary];
            [self.gradeArray addObject:gradeCourseDictionary];
            [gradeCourseDictionary setValue:self.user.userId forKey:GRADE_WHOGRADE];
        }
        switch (key % 11) {
            case 0:
                [gradeCourseDictionary setValue:[[element content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:COURSE_CODE];//课程代码
                break;
            case 1:
                [gradeCourseDictionary setValue:[[element content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:COURSE_ID];//课程序号
                break;
            case 2:
                [gradeCourseDictionary setValue:[[element content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:COURSE_NAME];//课程名称
                break;
            case 3:
                [gradeCourseDictionary setValue:[[element content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:GRADE_CATEGORY];//课程类别
                break;
            case 4:
                [gradeCourseDictionary setValue:[[element content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:GRADE_CREDIT];//学分
                break;
            case 5:
                [gradeCourseDictionary setValue:[[element content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:GRADE_MIDTERMGRADE];//期中成绩
                break;
            case 6:
                [gradeCourseDictionary setValue:[[element content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:GRADE_FINALLEVEL];//期末总评
                break;
            case 7:
                [gradeCourseDictionary setValue:[[element content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:GRADE_MAKEUPEXAMGRADE];//补考成绩
                break;
            case 8:
                [gradeCourseDictionary setValue:[[element content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:GRADE_FINALGRADE];//期末成绩
                break;
            case 9:
                [gradeCourseDictionary setValue:[[element content] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:GRADE_GRADEPOINT];//学分
                break;
            case 10:
            {
                NSArray *semesterAndYear =  [[element content] componentsSeparatedByString:@" "];
                NSString *year = [[[semesterAndYear firstObject] componentsSeparatedByString:@"-"] firstObject];
                [gradeCourseDictionary setValue:[NSNumber numberWithInteger:[year integerValue]] forKey:COURSE_STARTSCHOOLYEAR];//学年
                [gradeCourseDictionary setValue:[NSNumber numberWithInteger:[[semesterAndYear lastObject] integerValue]] forKey:COURSE_SEMESTER];//学期
            }
                break;
            default:
                break;
        }
        key++;
    }
    //数据保存到数据库
    
    [Grade loadGradeFromFlickrArray:self.gradeArray intoManagedObjectContext:self.managedObjectContext];
    [self.managedObjectContext save:NULL];
    [self.delegate downloadFinish:self];
}

#pragma - mark Coursetable
//开始获取用户的数据，并创建用户self.user
-(void)analyzeCoursesHtmlData:(NSData *)htmlData
{
    
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
    
    NSArray *elements  = [xpathParser searchWithXPathQuery:@"//table[@class='listTable']/tbody/tr[position()>2]/td"];
    if ([elements count]) {
        if (LX_DEBUG) {
            NSLog(@"[%@->%@] requestData",NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        }
    }
    [self saveCourseData:elements];
}

-(void)saveCourseData:(NSArray *)elements
{
    NSInteger whichLesson = 0;
    for (TFHppleElement *element in elements) {
        whichLesson++;
        if ([[element objectForKey:@"class"] isEqualToString:@"darkColumn"]) {//匹配星期几
            self.week = [element content];
            whichLesson = 0;
        }
        
        if ([element objectForKey:@"colspan"]) {
            self.sectionEnd = [[element objectForKey:@"colspan"] integerValue]+whichLesson-1;
            self.sectionStart = whichLesson;
            whichLesson = self.sectionEnd;
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
            [self analysisOfTheCourseDetailWith:course];
        }
    }
    //数据保存到数据库
    [Courses loadCourseFromFlickrArray:self.coursesArray intoManagedObjectContext:self.managedObjectContext];
    [self.managedObjectContext save:NULL];
    [self sendNotificationToCourseTable];
}

//分析找到的一门新课程
-(void)analysisOfTheCourseDetailWith:(NSString *)course
{
    /*@[王国强 多元微积分A（上）(0014), (1-8,B310多), 沈军 多元微积分A（下）(4477), (10-17,A307多)*/
    NSArray *courseArray = [course componentsSeparatedByString:@";"];
    
    for (NSString *courseDetail in courseArray) {
        if (![[courseDetail substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"("]) {
            if (self.courseDictionary) {
                if (LX_DEBUG) {
                    for (NSString *string in self.courseDictionary) {
                        NSLog(@"%@ = %@",string,self.courseDictionary[string]);
                    }
                    NSLog(@"-----------------------------------");
                }
                
            }
            self.courseDictionary = [self createACourseDictionary];
            [self.coursesArray addObject:self.courseDictionary];
            [self.courseDictionary setValue:[NSNumber numberWithInteger:self.sectionStart] forKey:COURSE_SECTIONSTART];//第几节开始上课
            [self.courseDictionary setValue:[NSNumber numberWithInteger:self.sectionEnd] forKey:COURSE_SECTIONEND];
            [self.courseDictionary setValue:[NSNumber numberWithInteger:2015] forKey:COURSE_STARTSCHOOLYEAR];//学年
            [self.courseDictionary setValue:[NSNumber numberWithInteger:2] forKey:COURSE_SEMESTER];//学期
            [self.courseDictionary setValue:self.user.userId forKey:COURSE_WHOCOURSE];//用户
            
            [self analyzeCourseNameAndTeacherWith:courseDetail];
        } else {
            
            [self analyzeCourseLocaleAndCourseTime:courseDetail];
        }
    }
}

//课程名称，教师名称
-(void)analyzeCourseNameAndTeacherWith:(NSString *)courseDetail
{
    NSArray *teacherAndcourseNameArray = [courseDetail componentsSeparatedByString:@" "];
    NSString *teacherName = [teacherAndcourseNameArray firstObject];
    NSString *temp = [teacherName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([teacherAndcourseNameArray count] > 1 && [temp length]) {
        for (NSString *teacher in teacherAndcourseNameArray) {
            NSLog(@"teacher = %@",teacher);
        }
        [self.courseDictionary setValue:[teacherAndcourseNameArray firstObject] forKey:COURSE_TEACHER];//老师
    } else {
        [self.courseDictionary setValue:@"待定" forKey:COURSE_TEACHER];
    }
    
    NSArray *courseNameAndIdArray = [[teacherAndcourseNameArray lastObject] componentsSeparatedByString:@"("];//高歌 电路(一)(3911);(1-8,C110多); 制造技术基础实习C(3897);(10-11,实训楼1号楼底楼7号门大厅)
    [self.courseDictionary setValue:[courseNameAndIdArray firstObject] forKey:COURSE_NAME];//课程名称
    
    NSString *courseId = [[courseNameAndIdArray lastObject] substringToIndex:[[courseNameAndIdArray lastObject]length]-1];
    [self.courseDictionary setValue:courseId forKey:COURSE_ID];//课程序号
#warning -咱用period做为课程唯一标识符
    NSString *period = [[[self weekToDay:self.week] stringByAppendingString:[NSString stringWithFormat:@"%ld",self.sectionStart]] stringByAppendingString:courseId];
    [self.courseDictionary setValue:period forKey:COURSE_PERIOD];
}

//上课时间和的点
-(void)analyzeCourseLocaleAndCourseTime:(NSString *)courseDetail
{
    if ([self.courseDictionary objectForKey:COURSE_DAY]) {
        //这种情况－－高燕 自动控制理论A(0524);(11,训1104-1111);(12-14,训1105);(1-8 10,D302多)
        NSString *oldLocale = [self.courseDictionary objectForKey:COURSE_LOCALE];//上课地点
        NSString *oldSmartPeriod = [self.courseDictionary objectForKey:COURSE_SMARTPERIOD];//具体上课的周
        
        NSArray *courseTimeAndLocaleArray = [courseDetail componentsSeparatedByString:@","];
        //上课时间
        NSString *courseTime = [[courseTimeAndLocaleArray firstObject] substringFromIndex:1];//4 8 双12-14
        NSString *smartPeriod = [self returnTotalSmartData:courseTime];
        
        [self.courseDictionary setValue:[oldLocale stringByAppendingString:[NSString stringWithFormat:@",%@",courseDetail]] forKey:COURSE_LOCALE];//上课地点
        [self.courseDictionary setValue:[oldSmartPeriod stringByAppendingString:smartPeriod] forKey:COURSE_SMARTPERIOD];
    } else {//这里只运行一次
        
        [self.courseDictionary setValue:[NSNumber numberWithInteger:[[self weekToDay:self.week] integerValue]] forKey:COURSE_DAY];
        NSArray *courseTimeAndLocaleArray = [courseDetail componentsSeparatedByString:@","];
        
        //上课时间
        NSString *courseTime = [[courseTimeAndLocaleArray firstObject] substringFromIndex:1];//4 8 双12-14
        NSString *smartPeriod = [self returnTotalSmartData:courseTime];
        
        [self.courseDictionary setValue:courseDetail forKey:COURSE_LOCALE];//上课地点
        [self.courseDictionary setValue:smartPeriod forKey:COURSE_SMARTPERIOD];
    }
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
