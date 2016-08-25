//
//  User+Create.h
//  SUES
//
//  Created by lixu on 16/8/17.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import "User.h"

@interface User (Create)

+(User *)userWithName:(NSDictionary *)userDictionary inManagedObjectContext:(NSManagedObjectContext *)context;
+(User *)searchUserWithId:(NSString *)userId inManagedObjectContext:(NSManagedObjectContext *)context;
@end
