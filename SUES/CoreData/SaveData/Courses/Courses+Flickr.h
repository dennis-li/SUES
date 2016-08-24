//
//  Courses+Flickr.h
//  SUES
//
//  Created by lixu on 16/8/17.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import "Courses.h"

@interface Courses (Flickr)
+(Courses *)courseWithFlickrInfo:(NSDictionary *)courseDictionary inManagedObjectContext:(NSManagedObjectContext *)context;
+(void)loadCourseFromFlickrArray:(NSArray *)courseData intoManagedObjectContext:(NSManagedObjectContext *)context;
@end
