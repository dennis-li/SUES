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

@interface AppDelegate ()<NSURLSessionDownloadDelegate>
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
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
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
        [self changeRootCtroller:YES];
    }
}

-(void)changeRootCtroller:(BOOL)isLogin
{
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:250.0f/255.0f green:210.0f/255.0f blue:40.0f/255.0f alpha:1.0f]];
    UIViewController *rootVCT = nil;
    if (isLogin) {
        MainTabBarController *tabCtrl = [[MainTabBarController alloc] init];
        self.window.rootViewController = tabCtrl;
        rootVCT = tabCtrl;
    }else {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.window.rootViewController = [storyBoard instantiateInitialViewController];
        rootVCT = [storyBoard instantiateInitialViewController];
    }
    [UIView transitionWithView:[[UIApplication sharedApplication].delegate window]
                      duration:1
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        BOOL oldState=[UIView areAnimationsEnabled];
                        [UIView setAnimationsEnabled:NO];
                        [[[UIApplication sharedApplication].delegate window] setRootViewController:rootVCT];
                        [UIView setAnimationsEnabled:oldState];
                        
                    }
                    completion:NULL];
}

//允许在后台做一些事情
-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSLog(@"startBackRequestData");
    if (self.managedObjectContext) {
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        sessionConfig.allowsCellularAccess = NO;
        sessionConfig.timeoutIntervalForRequest = 10; // want to be a good background citizen!
        NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://autoapp.auto.sohu.com/api/columnnews/list_%@_%@_20",@"3",@"0"]];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
                                                        completionHandler:^(NSURL *localFile, NSURLResponse *response, NSError *error) {
                                                            if (error) {
                                                                NSLog(@"Flickr background fetch failed: %@", error.localizedDescription);
                                                                completionHandler(UIBackgroundFetchResultNoData);
                                                            } else {
                                                                NSDictionary *flickrPropertyList;
                                                                NSData *flickrJSONData = [NSData dataWithContentsOfURL:localFile];
                                                                flickrPropertyList = [NSJSONSerialization JSONObjectWithData:flickrJSONData
                                                                                                                     options:0
                                                                                                                       error:NULL];
                                                            
                                                            if (LX_DEBUG) {
                                                                NSLog(@"downloadResult = %@",flickrPropertyList);
                                                            }
                                                            
                                                            
                                                                NSLog(@"List = %@",[[flickrPropertyList valueForKeyPath:@"result.newsList"] firstObject]);
                                                            }
                                                        }];
        [task resume];
    } else {
        completionHandler(UIBackgroundFetchResultNoData); // no app-switcher update if no database!
    }
}


-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    
}

-(void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    
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

#pragma mark - NSURLSessionDownloadDelegate

//文件完成下载
// required by the protocol

/*六*/
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)localFile
{
    // we shouldn't assume we're the only downloading going on ...
    
}

//- (void)URLSession:(NSURLSession *)session
//      downloadTask:(NSURLSessionDownloadTask *)downloadTask
//didFinishDownloadingToURL:(NSURL *)localFile
//{
//    if ([downloadTask.taskDescription isEqualToString:FLICKR_FETCH]) {
//        NSManagedObjectContext *context = self.photoDatabaseContext;
//        if (context) {
//            NSArray *photos = [self flickrPhotosAtURL:localFile];
//        }
//    }
//}

//下载可以打断，然后继续
// required by the protocol
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
    // we don't support resuming an interrupted download task
}

// required by the protocol//下载进度，完成了多少字节
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    // we don't report the progress of a download in our UI, but this is a cool method to do that with
}


/*
 /不需要的协议,但我们应该捕获错误
 / /这样我们就可以避免碰撞事故的发生
 / /也这样我们可以检测到下载任务(可能)完成
 */
// not required by the protocol, but we should definitely catch errors here
// so that we can avoid crashes
// and also so that we can detect that download tasks are (might be) complete
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    
}

// this is "might" in case some day we have multiple downloads going on at once
//这是“可能”,以防有一天我们有多个下载
//从这里获取所有的flickr下载session所做的任务
- (void)flickrDownloadTasksMightBeComplete
{
   
}


@end
