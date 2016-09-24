//
//  Grade+Flickr.m
//  SUES
//
//  Created by lixu on 16/8/18.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import "Grade+Flickr.h"
#import "Public.h"
#import "User+Create.h"

@implementation Grade (Flickr)
//把照片存储到数据库
+(Grade *)gradeWithFlickrInfo:(NSDictionary *)gradeDictionary inManagedObjectContext:(NSManagedObjectContext *)context 
{
    Grade *grade = nil;
    User *user = [User searchUserWithId:gradeDictionary[GRADE_WHOGRADE] inManagedObjectContext:context];
    NSString *courseId = gradeDictionary[COURSE_ID];
    if (!gradeDictionary[COURSE_NAME]) {
        return nil;
    }
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Grade"];
    request.predicate = [NSPredicate predicateWithFormat:@"whoGrade = %@ AND courseId = %@ AND courseCode = %@",user,courseId,gradeDictionary[COURSE_CODE]];
    
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    if (!matches || error || ([matches count] > 1)) {
        //handle error
    } else if ([matches count]){
        grade = [matches firstObject];
        grade.courseCode = gradeDictionary[COURSE_CODE];
        grade.category = gradeDictionary[GRADE_CATEGORY];
        grade.name = [gradeDictionary[COURSE_NAME] stringByAppendingString:@"+"];
        grade.credit = gradeDictionary[GRADE_CREDIT];
        grade.midTermGrade = gradeDictionary[GRADE_MIDTERMGRADE];
        grade.finalLevel = gradeDictionary[GRADE_FINALLEVEL];
        grade.makeupExamGrade = gradeDictionary[GRADE_MAKEUPEXAMGRADE];
        grade.finalGrade = gradeDictionary[GRADE_FINALGRADE];
        grade.gradePoint = gradeDictionary[GRADE_GRADEPOINT];
        
    } else {
        //最后返回的可能是空数组
        grade = [NSEntityDescription insertNewObjectForEntityForName:@"Grade" inManagedObjectContext:context];
        grade.courseId = courseId;
        grade.courseCode = gradeDictionary[COURSE_CODE];
        grade.category = gradeDictionary[GRADE_CATEGORY];
        grade.name = gradeDictionary[COURSE_NAME];
        grade.credit = gradeDictionary[GRADE_CREDIT];
        grade.midTermGrade = gradeDictionary[GRADE_MIDTERMGRADE];
        grade.finalLevel = gradeDictionary[GRADE_FINALLEVEL];
        grade.makeupExamGrade = gradeDictionary[GRADE_MAKEUPEXAMGRADE];
        grade.finalGrade = gradeDictionary[GRADE_FINALGRADE];
        grade.gradePoint = gradeDictionary[GRADE_GRADEPOINT];
        grade.startSchoolYear = gradeDictionary[COURSE_STARTSCHOOLYEAR];
        grade.semester = gradeDictionary[COURSE_SEMESTER];
        grade.yearAndSemester = gradeDictionary[COURSE_YEARANDSEMESTER];
        grade.whoGrade = [User searchUserWithId:gradeDictionary[GRADE_WHOGRADE] inManagedObjectContext:context];
    }
    if (LX_DEBUG) {
        NSLog(@"Grade.Flickr_year = %@,semester = %@",grade.startSchoolYear,grade.semester);
    }
    return grade;
}

//批量加载数据
+(void)loadGradeFromFlickrArray:(NSArray *)gradeData intoManagedObjectContext:(NSManagedObjectContext *)context
{
    for (NSDictionary *grade in gradeData) {
        [self gradeWithFlickrInfo:grade inManagedObjectContext:context];
    }
}

@end
