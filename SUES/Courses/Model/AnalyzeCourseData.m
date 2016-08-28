//
//  AnalyzeCourseData.m
//  SUES
//
//  Created by lixu on 16/8/28.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import "AnalyzeCourseData.h"
#import "TFHpple.h"
#import "Public.h"
#import "User+Create.h"
#import "Courses+Flickr.h"
#import "AppDelegate.h"

@interface AnalyzeCourseData ()
@property (nonatomic ,strong) NSMutableArray *coursesArray;//存放所有课程
@property (nonatomic ,strong) User *user;
@property (nonatomic ,strong) NSMutableDictionary *courseDictionary;//存放一个课程详情
@property (nonatomic ,assign) NSInteger sectionStart;//从第几节开始上课
@property (nonatomic ,assign) NSInteger sectionEnd;
@property (nonatomic ,strong) NSString *week;//课程的Day，那天上课
@end

@implementation AnalyzeCourseData
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
    NSDictionary *userInfo = @{@"context" : self.user.managedObjectContext};
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"sendContextToCourseTable"
     object:self
     userInfo:userInfo];
}

//解析课表数据
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
    [Courses loadCourseFromFlickrArray:self.coursesArray intoManagedObjectContext:self.user.managedObjectContext];
    [self.user.managedObjectContext save:NULL];
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
#warning 学年，学期需匹配
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
