//
//  User+Create.m
//  SUES
//
//  Created by lixu on 16/8/17.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import "User+Create.h"
#import "Public.h"

@implementation User (Create)

+(User *)userWithName:(NSDictionary *)userDictionary inManagedObjectContext:(NSManagedObjectContext *)context
{
    User *user = nil;
    
    if ([userDictionary count]) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
        request.predicate = [NSPredicate predicateWithFormat:@"userId = %@",userDictionary[USER_ID]];
        
        NSError *error;
        NSArray *matches = [context executeFetchRequest:request error:&error];
        
        if (!matches || ([matches count] > 1)) {
            // handle error
        } else if (![matches count]) {
            user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
            user.name = userDictionary[USER_NAME];
            user.password = userDictionary[USER_PASSWORD];
            user.userId = userDictionary[USER_ID];
        } else {
            user = [matches lastObject];
        }
    }
    return user;
}

+(User *)searchUserWithId:(NSString *)userId inManagedObjectContext:(NSManagedObjectContext *)context
{
    User *user = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    request.predicate = [NSPredicate predicateWithFormat:@"userId = %@",userId];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        // handle error
    } else if (![matches count]) {
       
    } else {
        user = [matches lastObject];
    }
    return user;
}
@end
