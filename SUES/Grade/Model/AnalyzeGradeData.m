//
//  AnalyzeGradeData.m
//  SUES
//
//  Created by lixu on 16/8/28.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import "AnalyzeGradeData.h"
#import "TFHpple.h"
#import "User+Create.h"
#import "Grade+Flickr.h"
#import "AppDelegate.h"
#import "Public.h"

@interface AnalyzeGradeData ()
@property (nonatomic ,strong) User *user;
@property (nonatomic ,strong) NSMutableArray *gradeArray;//存放所有的成绩
@property (nonatomic ,strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic ,strong) NSMutableDictionary *userDictionary;//存放user的信息
@end

@implementation AnalyzeGradeData
-(User *)user
{
    if (!_user) {
        _user = [self returnApp].user;
    }
    return _user;
}

-(NSManagedObjectContext *)managedObjectContext
{
    if (!_managedObjectContext) {
        _managedObjectContext = [self returnApp].managedObjectContext;
    }
    return _managedObjectContext;
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

-(NSMutableArray *)gradeArray
{
    if (!_gradeArray) {
        _gradeArray = [[NSMutableArray alloc ] init];
    }
    return _gradeArray;
}

//返回一个字典，存储成绩详情
-(NSMutableDictionary *)createAGradeDictionary
{
    return [[NSMutableDictionary alloc] init];
}

-(void)analyzeGradeHtmlData:(NSData *)htmlData userId:(NSString *)userId userPassword:(NSString *)userPassword
{
    [self.userDictionary setValue:userId  forKey:USER_ID];
    [self.userDictionary setValue:userPassword forKey:USER_PASSWORD];
    [self analyzeGradeHtmlData:htmlData];
}

//解析成绩html数据
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
            gradeCourseDictionary = [self createAGradeDictionary];
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
                
                [gradeCourseDictionary setValue:[element content] forKey:COURSE_YEARANDSEMESTER];
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
}
@end
