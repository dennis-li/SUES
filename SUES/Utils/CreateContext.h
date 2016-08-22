//
//  CreateContext.h
//  SUES
//
//  Created by lixu on 16/8/18.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CreateContext : NSObject
+(NSManagedObjectContext *)createContext;
@end
