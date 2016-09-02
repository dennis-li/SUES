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

//软件要随时知道现在的学期号semesterID,和用户的服务器学号studentID
@property (strong, nonatomic) NSString *semesterID;
@property (strong, nonatomic) NSString *studentID;

-(void)changeRootCtroller:(BOOL)isLogin;

//请求考试安排
-(void)requestSemesterIDAndStudentID:(User *)user;
@end

