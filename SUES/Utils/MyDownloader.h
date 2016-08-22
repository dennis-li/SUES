//
//  MyDownloader.h
//  SohuByObject_C
//
//  Created by lixu on 16/4/25.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MyDownloader;
@protocol MyDownloaderDelegate <NSObject>

//下载失败
- (void)downloadFail:(MyDownloader *)downloader error:(NSError  *)error;

//下载成功
- (void)downloadFinish:(MyDownloader *)downloader;

@end

@interface MyDownloader : NSObject<NSURLConnectionDataDelegate,NSURLConnectionDelegate>
{
    NSMutableData *_receiveData;
    NSURLConnection *_conn;
}

//代理属性
@property (nonatomic,weak)id<MyDownloaderDelegate>delegate;
@property (nonatomic,strong)NSData *receiveData;
//类型
@property (nonatomic,strong)NSString *type;

//下载
- (void)downloadWithUrlString:(NSString *)urlString;
@end
