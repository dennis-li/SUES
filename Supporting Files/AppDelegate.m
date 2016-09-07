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
#import "TFHpple.h"
#import "AnalyzeExamData.h"
#import "AnalyzeAnswerQuestionData.h"

@interface AppDelegate ()<NSURLSessionDownloadDelegate>
@property (readwrite, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSURLSession *flickrDownloadSession;
@end

@implementation AppDelegate
-(NSManagedObjectContext *)managedObjectContext
{
    if (!_managedObjectContext) {
        _managedObjectContext = [CreateContext createContext];
    }
    return _managedObjectContext;
}

- (NSURLSession *)flickrDownloadSession
{
    if (!_flickrDownloadSession) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _flickrDownloadSession = [NSURLSession sharedSession];
        });
    }
    return _flickrDownloadSession;
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
    NSArray *courseArray = [self.managedObjectContext executeFetchRequest:request error:nil];
    
    if ([courseArray count]) {
        self.user = [courseArray lastObject];
        [self changeRootCtroller:YES];
    }
}

-(void)changeRootCtroller:(BOOL)isLogin
{
//    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:250.0f/255.0f green:210.0f/255.0f blue:40.0f/255.0f alpha:1.0f]];
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

#pragma -mark 考试安排
//清除cookie
-(void)cleanCookie
{
    NSArray *array =  [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:SUES_URL]];
    for (NSHTTPCookie *cookie in array)
    {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
}

//请求考试安排数据，的前期请求
-(void)requestSemesterIDAndStudentID:(User *)user
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);//一次只能做一个任务
        [self verifyRequest:^(NSString *error) {//登录服务器
            if (error) {
                dispatch_semaphore_signal(semaphore);
                [NSThread exit];
            }else {
                dispatch_semaphore_signal(semaphore);
            }
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);//上一个任务做完，接着做下一个
        [self startSemesterAndStudentIdData:^(NSString *error) {//请求当前学期号，用户服务器学生号
            if (error) {
                dispatch_semaphore_signal(semaphore);
                [NSThread exit];
            }else {
                dispatch_semaphore_signal(semaphore);
            }
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        dispatch_async(dispatch_get_main_queue(), ^{//请求考试安排数据
            [self startRequestAnswerQuestionData:user];
            [self startRequestExamData:user];
        });
    });
}

//向服务器验证登录信息
-(void)verifyRequest:(void(^)(NSString *error))requestMessage
{
    [self cleanCookie];
    NSURL *url = [NSURL URLWithString:@"http://my.sues.edu.cn/userPasswordValidate.portal"];
    
    //2.构造Request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.timeoutInterval = 10;
    
    NSDictionary *parameters = @{@"Login.Token1":self.user.userId,
                                 @"Login.Token2":self.user.password,
                                 @"capatcha":FORM_CAPATCHA,
                                 @"goto":FORM_SUCCESS,
                                 @"gotoOnFaili":FORM_GOTOONFILI
                                 };
    // 4.2、遍历字典，以“key=value&”的方式创建参数字符串。
    NSMutableString *parameterString = [NSMutableString string];
    for (NSString *key in parameters.allKeys) {
        [parameterString appendFormat:@"%@=%@&", key, parameters[key]];
    }
    NSString *str = [parameterString substringToIndex:parameterString.length - 1];
    NSString *requestString = [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#+-!?*@%$~^_{}\"[]|\\<> "].invertedSet];//对特殊字符进行编码
    NSData *parametersData = [requestString dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPBody = parametersData;
    
    NSURLSessionDataTask *task = [self.flickrDownloadSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if ([result containsString:@"handleLoginSuccessed"]) {
            requestMessage(nil);
        } else if ([result containsString:@"handleLoginFailure"]) {
            requestMessage(@"密码或用户名错误");
        } else {
            requestMessage(@"请检查网络");
        }
        
    }];
    [task resume];
}

#pragma - mark 请求并解析学期号，服务器学号
-(void)startSemesterAndStudentIdData:(void(^)(NSString *error))requestMessage
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:COURSE_GET_URL]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    NSURLSessionDownloadTask *task = [self.flickrDownloadSession downloadTaskWithRequest:request
                                                                       completionHandler:^(NSURL *localFile, NSURLResponse *response, NSError *error) {
                                                                           if (error) {
                                                                               requestMessage(error.localizedDescription);
                                                                           } else {
                                                                               NSString *result = [NSString stringWithContentsOfURL:localFile encoding:NSUTF8StringEncoding error:nil];
                                                                               [self analyzeUserStudentIDAndSmesterID:result requestMessage:requestMessage];
                                                                           }
                                                                       }];
    [task resume];
}

//解析学期号，服务器学号
-(void)analyzeUserStudentIDAndSmesterID:(NSString *)htmlString
                         requestMessage:(void(^)(NSString *error))requestMessage

{
    NSData *htmlData=[htmlString dataUsingEncoding:NSUTF8StringEncoding];
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
    NSArray *elements  = [xpathParser searchWithXPathQuery:@"//table[@class='frameTable']/tr/td/iframe"];
    for (TFHppleElement *element in elements) {
        if ([[element objectForKey:@"id"] isEqualToString:@"contentListFrame"]) {
            NSLog(@"url = %@",[element objectForKey:@"src"]);
            NSString *coursesURL = [element objectForKey:@"src"];
            NSLog(@"courseURL = %@",coursesURL);
            NSArray *idsArray = [coursesURL componentsSeparatedByString:@"&"];
            for (NSString *idsString in idsArray) {
                NSArray *idsDetailArray = [idsString componentsSeparatedByString:@"="];
                if ([[idsDetailArray firstObject] containsString:@"semester.id"]) {
                    if (LX_DEBUG) {
                        NSLog(@"semesterID = %@",[idsDetailArray lastObject]);
                    }
                    self.semesterID = [idsDetailArray lastObject];
                } else if([[idsDetailArray firstObject] isEqualToString:@"ids"]) {
                    if (LX_DEBUG) {
                        NSLog(@"studentID = %@",[idsDetailArray lastObject]);
                    }
                    self.studentID = [idsDetailArray lastObject];
                }
            }
        }
    }
    requestMessage(nil);
}

#pragma - mark 请求并解析学期号，服务器学号
-(void)startRequestExamData:(User *)user
{
    AnalyzeExamData *analyzeExamData = [[AnalyzeExamData alloc] init];
    analyzeExamData.managedObjectContext = self.managedObjectContext;
    dispatch_group_t downloadGroup = dispatch_group_create();
    
    dispatch_apply(4, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(size_t i) {
        
        dispatch_group_enter(downloadGroup);//调度组
        if (i > 0) {
            [self requestExamDataWithSemesterID:self.semesterID examType:i requestMessage:^(NSString *requestMessage, NSString *error) {
                [analyzeExamData analyzeExamHtmlData:[requestMessage dataUsingEncoding:NSUTF8StringEncoding] userId:user.userId examType:[NSString stringWithFormat:@"%ld",i] semesterId:self.semesterID];
                dispatch_group_leave(downloadGroup);
            }];
        }else {
            NSString *semesterId = [NSString stringWithFormat:@"%ld",[self.semesterID integerValue]-1];
            //1表示期末考试
            [self requestExamDataWithSemesterID:semesterId examType:3l requestMessage:^(NSString *requestMessage, NSString *error) {
                [analyzeExamData analyzeExamHtmlData:[requestMessage dataUsingEncoding:NSUTF8StringEncoding] userId:user.userId examType:[NSString stringWithFormat:@"%ld",3l] semesterId:semesterId];
                dispatch_group_leave(downloadGroup);
            }];
        }
    });
    
    dispatch_group_notify(downloadGroup, dispatch_get_main_queue(), ^{//调度组所有任务结束
        NSLog(@"all.request");
    });
}

//请求对应类型的考试安排
-(void)requestExamDataWithSemesterID:(NSString *)semesterID examType:(NSInteger)examType requestMessage:(void(^)(NSString *requestMessage,NSString *error))requestMessage
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:EXAM_URL,semesterID,examType]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    NSURLSessionDownloadTask *task = [self.flickrDownloadSession downloadTaskWithRequest:request
                                                                       completionHandler:^(NSURL *localFile, NSURLResponse *response, NSError *error) {
                                                                           if (error) {
                                                                           } else {
                                                                               NSString *result = [NSString stringWithContentsOfURL:localFile encoding:NSUTF8StringEncoding error:nil];
                                                                               requestMessage(result,nil);
                                                                           }
                                                                       }];
    [task resume];
}

#pragma -mark 请求并解析答疑安排
-(void)startRequestAnswerQuestionData:(User *)user
{
    AnalyzeAnswerQuestionData *analyzeAnswerQuestionData = [[AnalyzeAnswerQuestionData alloc] init];
    analyzeAnswerQuestionData.managedObjectContext = self.managedObjectContext;
    dispatch_group_t downloadGroup = dispatch_group_create();
    
    dispatch_apply(2, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(size_t i) {
        NSString *semester = [NSString stringWithFormat:@"%ld",[self.semesterID integerValue]-i];
        dispatch_group_enter(downloadGroup);//调度组
        [self requestAnswerQuestionDataWithSemesterID:semester requestMessage:^(NSString *requestMessage, NSString *error) {
            [analyzeAnswerQuestionData analyzeAnswerQuestionHtmlData:[requestMessage dataUsingEncoding:NSUTF8StringEncoding] userId:user.userId semesterId:semester];
            dispatch_group_leave(downloadGroup);
        }];
    });
    
    dispatch_group_notify(downloadGroup, dispatch_get_main_queue(), ^{//调度组所有任务结束
        NSLog(@"all.request");
    });
}

-(void)requestAnswerQuestionDataWithSemesterID:(NSString *)semesterID requestMessage:(void(^)(NSString *requestMessage,NSString *error))requestMessage
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:ANSWER_QUESTION_PLAN,semesterID]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    NSURLSessionDownloadTask *task = [self.flickrDownloadSession downloadTaskWithRequest:request
                                                                       completionHandler:^(NSURL *localFile, NSURLResponse *response, NSError *error) {
                                                                           if (error) {
                                                                           } else {
                                                                               NSString *result = [NSString stringWithContentsOfURL:localFile encoding:NSUTF8StringEncoding error:nil];
                                                                               NSLog(@"answerQuestion.html = %@",result);                     requestMessage(result,nil);
                                                                           }
                                                                       }];
    [task resume];
}

#pragma - mark 允许在后台做一些事情
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
