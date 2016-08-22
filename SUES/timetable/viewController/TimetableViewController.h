//
//  TimetableViewController.h
//  gcdqn
//
//  Created by admin on 16/7/19.
//  Copyright © 2016年 hardtosaygoodbye. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User+Create.h"
#import <CoreData/CoreData.h>

@interface TimetableViewController : UIViewController
@property (nonatomic,strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,strong) User *user;
@end
