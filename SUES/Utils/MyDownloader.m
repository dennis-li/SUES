//
//  MyDownloader.m
//  SohuByObject_C
//
//  Created by lixu on 16/4/25.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import "MyDownloader.h"

@implementation MyDownloader

-(instancetype)init
{
    if (self = [super init]) {
        _receiveData = [NSMutableData data];
    }
    return self;
}

-(void)downloadWithUrlString:(NSString *)urlString
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    _conn = [NSURLConnection connectionWithRequest:request delegate:self];
}

#pragma mark - NSURLConnection代理
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self.delegate downloadFinish:self];
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(nonnull NSData *)data
{
    [_receiveData appendData:data];
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.delegate downloadFail:self error:error];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(nonnull NSURLResponse *)response
{
    [_receiveData setLength:0];
}
@end
