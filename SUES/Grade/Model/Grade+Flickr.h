//
//  Grade+Flickr.h
//  SUES
//
//  Created by lixu on 16/8/18.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import "Grade.h"

@interface Grade (Flickr)
+(Grade *)gradeWithFlickrInfo:(NSDictionary *)gradeDictionary inManagedObjectContext:(NSManagedObjectContext *)context;
+(void)loadGradeFromFlickrArray:(NSArray *)gradeData intoManagedObjectContext:(NSManagedObjectContext *)context;
@end
