//
//  MyUtil.h
//  SohuByObject_C
//
//  Created by lixu on 16/4/7.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MyUtil : NSObject

+ (UILabel *)createLabel:(CGRect)frame title:(NSString *)title font:(UIFont*)font textAlignment:(NSTextAlignment)textAlignment textColor:(UIColor*)textColor;
+ (UIButton *)createBtn:(CGRect)frame bgImageName:(NSString*)bgImageName selectBgImageName:(NSString*)selectBgImageName highlighBgImageName:(NSString*)highlighBgImageName title:(NSString*)title target:(id)target action:(SEL)action;
+ (UIImageView *)createImageView:(CGRect)frame imageName:(NSString*)imageName;
+ (UITextField *)createTextField:(CGRect)frame placeHolder:(NSString*)placeHolder isSecury:(BOOL)isSecury;
//类型转换文字
+(NSString *)transferCateName:(NSString*)name;

+ (UILabel *)createLabelFrame:(CGRect)frame title:(NSString *)title;

+ (UIButton *)createBtnFrame:(CGRect)frame type:(UIButtonType)type bgImageName:(NSString *)bgImageName title:(NSString *)title target:(id)target action:(SEL)action;

+ (UIImageView *)createImageViewFrame:(CGRect)frame imageName:(NSString *)imageName;
@end

/**
 
 if name == "Business" {
 return "商业"
 }else if name == "Weather" {
 return "天气"
 }else if name == "Tool" {
 return "工具"
 }else if name == "Travel" {
 return "旅行"
 }else if name == "Sports" {
 return "体育"
 }else if name == "Social" {
 return "社交"
 }else if name == "Refer" {
 return "参考"
 }else if name == "Ability" {
 return "效率"
 }else if name == "Photography" {
 return "摄影"
 }else if name == "News" {
 return "新闻"
 }else if name == "Gps" {
 return "导航"
 }else if name == "Music" {
 return "音乐"
 }else if name == "Life" {
 return "生活"
 }else if name == "Health" {
 return "健康"
 }else if name == "Finance" {
 return "财务"
 }else if name == "Pastime" {
 return "娱乐"
 }else if name == "Education" {
 return "教育"
 }else if name == "Book" {
 return "书籍"
 }else if name == "Medical" {
 return "医疗"
 }else if name == "Catalogs" {
 return "商品指南"
 }else if name == "FoodDrink" {
 return "美食"
 }else if name == "Game" {
 return "游戏"
 }else if name == "All" {
 return "全部"
 }
 */
