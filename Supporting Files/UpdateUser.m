//
//  UpdateUser.m
//  SUES
//
//  Created by lixu on 16/8/20.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import "UpdateUser.h"
#import "AppDelegate.h"

@implementation UpdateUser

-(void)updateUser:(User *)user
{
    AppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    appdelegate.user = user;
}

@end
