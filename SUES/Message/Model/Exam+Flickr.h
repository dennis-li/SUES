//
//  Exam+Flickr.h
//  SUES
//
//  Created by lixu on 16/8/30.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import "Exam.h"

@interface Exam (Flickr)
+(Exam *)examWithFlickrInfo:(NSDictionary *)examDictionary inManagedObjectContext:(NSManagedObjectContext *)context;
//批量加载数据
+(void)loadExamFromFlickrArray:(NSArray *)examData intoManagedObjectContext:(NSManagedObjectContext *)context;
@end
