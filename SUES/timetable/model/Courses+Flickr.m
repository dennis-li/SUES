//
//  Courses+Flickr.m
//  SUES
//
//  Created by lixu on 16/8/17.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import "Courses+Flickr.h"
#import "Public.h"
#import "User+Create.h"

@implementation Courses (Flickr)

//存储到数据库
+(Courses *)courseWithFlickrInfo:(NSDictionary *)gradeDictionary inManagedObjectContext:(NSManagedObjectContext *)context
{
    Courses *course = nil;
    
    NSString *period = gradeDictionary[COURSE_PERIOD];
    if (!gradeDictionary[COURSE_NAME]) {
        return nil;
    }
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Courses"];
    request.predicate = [NSPredicate predicateWithFormat:@"period = %@",period];
    
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    if (!matches || error || ([matches count] > 1)) {
        //handle error
    } else if ([matches count]){
        course = [matches firstObject];
    } else {
        //最后返回的可能是空数组
        course = [NSEntityDescription insertNewObjectForEntityForName:@"Courses" inManagedObjectContext:context];
        course.teacher = gradeDictionary[COURSE_TEACHER];
        course.courseId = gradeDictionary[COURSE_ID];
        course.locale = gradeDictionary[COURSE_LOCALE];
        course.day = gradeDictionary[COURSE_DAY];
        course.name = gradeDictionary[COURSE_NAME];
        course.sectionend = gradeDictionary[COURSE_SECTIONEND];
        course.sectionstart = gradeDictionary[COURSE_SECTIONSTART];
        course.smartPeriod = gradeDictionary[COURSE_SMARTPERIOD];
        course.startSchoolYear = gradeDictionary[COURSE_STARTSCHOOLYEAR];
        course.semester = gradeDictionary[COURSE_SEMESTER];
        course.whoCourse = [User userWithName:gradeDictionary[COURSE_WHOCOURSE] inManagedObjectContext:context];
        NSLog(@"course.teacher = %@",course.teacher);
#warning period
        course.period = period;
    }
    return course;
}

//批量加载数据
+(void)loadCourseFromFlickrArray:(NSArray *)courseData intoManagedObjectContext:(NSManagedObjectContext *)context
{
    for (NSDictionary *course in courseData) {
        [self courseWithFlickrInfo:course inManagedObjectContext:context];
    }
}

@end
