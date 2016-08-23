//
//  AppDelegate.h
//  SUES
//
//  Created by lixu on 16/8/15.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "User.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) User *user;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,strong) NSMutableDictionary *userDictionary;
@property (nonatomic,strong)NSMutableArray *coursesArray;

-(void)changeRootCtroller;
-(void)startUserDataWithUserDetail:(NSString *)HTMLData userId:(NSString *)userId userPassWord:(NSString *)userPassWord;

@end

