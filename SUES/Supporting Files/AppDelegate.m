//
//  AppDelegate.m
//  SUES
//
//  Created by lixu on 16/8/15.
//  Copyright © 2016年 lixu. All rights reserved.
//KEY

#import "AppDelegate.h"
#import "MainTabBarController.h"
#import "CreateContext.h"
#import "Public.h"
#import <AFNetworking.h>

@interface AppDelegate ()
@property (readwrite, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation AppDelegate
-(NSManagedObjectContext *)managedObjectContext
{
    if (!_managedObjectContext) {
        _managedObjectContext = [CreateContext createContext];
    }
    return _managedObjectContext;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self checkLogin];
    return YES;
}

-(void)checkLogin
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    //    request.predicate = [NSPredicate predicateWithFormat:@"whoCourse = %@", self.user];
    NSArray *courseArray = [self.managedObjectContext executeFetchRequest:request error:nil];
    
    if ([courseArray count]) {
        self.user = [courseArray lastObject];
        [self changeRootCtroller];
    }
}

-(void)changeRootCtroller
{
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:250.0f/255.0f green:210.0f/255.0f blue:40.0f/255.0f alpha:1.0f]];
    MainTabBarController *tabCtrl = [[MainTabBarController alloc] init];
//    self.window.rootViewController = tabCtrl;
    
    [UIView transitionWithView:[[UIApplication sharedApplication].delegate window]
                      duration:1
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        BOOL oldState=[UIView areAnimationsEnabled];
                        [UIView setAnimationsEnabled:NO];
                        [[[UIApplication sharedApplication].delegate window] setRootViewController:tabCtrl];
                        [UIView setAnimationsEnabled:oldState];
                        
                    }
                    completion:NULL];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    
}


@end
