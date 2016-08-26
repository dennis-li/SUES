//
//  MyUtil.m
//  SohuByObject_C
//
//  Created by lixu on 16/4/7.
//  Copyright © 2016年 lixu. All rights reserved.
//


#import "MyUtil.h"

@implementation MyUtil

+(UILabel*)createLabel:(CGRect)frame title:(NSString *)title font:(UIFont *)font textAlignment:(NSTextAlignment)textAlignment textColor:(UIColor *)textColor
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    if (nil != title) {
        label.text = title;
    }
    label.font = font;
    label.textColor = textColor;
    return label;
}
+(UIButton*)createBtn:(CGRect)frame bgImageName:(NSString *)bgImageName selectBgImageName:(NSString *)selectBgImageName highlighBgImageName:(NSString *)highlighBgImageName title:(NSString *)title target:(id)target action:(SEL)action
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    if (nil != bgImageName) {
        [btn setBackgroundImage:[UIImage imageNamed:bgImageName] forState:UIControlStateNormal];
    }
    if (nil != selectBgImageName) {
        [btn setBackgroundImage:[UIImage imageNamed:selectBgImageName] forState:UIControlStateSelected];
    }
    if (nil != highlighBgImageName) {
        [btn setBackgroundImage:[UIImage imageNamed:highlighBgImageName] forState:UIControlStateHighlighted];
    }
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return btn;
}
+(UIImageView*)createImageView:(CGRect)frame imageName:(NSString *)imageName
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    if (nil != imageName) {
        imageView.image = [UIImage imageNamed:imageName];
    }
    return imageView;
}
+(UITextField *)createTextField:(CGRect)frame placeHolder:(NSString *)placeHolder isSecury:(BOOL)isSecury
{
    UITextField *textField = [[UITextField alloc] initWithFrame:frame];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.secureTextEntry = isSecury;
    textField.placeholder = placeHolder;
    return textField;
}
+(NSString *)transferCateName:(NSString *)name
{
    if ([name isEqualToString: @"Business"]) {
        return @"商业";
    }else if ([name isEqualToString: @"Weather"]) {
        return @"天气";
    }else if ([name isEqualToString: @"Tool"]) {
        return @"工具";
    }else if ([name isEqualToString: @"Travel"]) {
        return @"旅行";
    }else if ([name isEqualToString: @"Sports"]) {
        return @"体育";
    }else if ([name isEqualToString: @"Social"]) {
        return @"社交";
    }else if ([name isEqualToString: @"Refer"]) {
        return @"参考";
    }else if ([name isEqualToString: @"Ability"]) {
        return @"效率";
    }else if ([name isEqualToString: @"Photography"]) {
        return @"摄影";
    }else if ([name isEqualToString: @"News"]) {
        return @"新闻";
    }else if ([name isEqualToString: @"Gps"]) {
        return @"导航";
    }else if ([name isEqualToString: @"Music"]) {
        return @"音乐";
    }else if ([name isEqualToString: @"Life"]) {
        return @"生活";
    }else if ([name isEqualToString: @"Health"]) {
        return @"健康";
    }else if ([name isEqualToString: @"Finance"]) {
        return @"财务";
    }else if ([name isEqualToString: @"Pastime"]) {
        return @"娱乐";
    }else if ([name isEqualToString: @"Education"]) {
        return @"教育";
    }else if ([name isEqualToString: @"Book"]) {
        return @"书籍";
    }else if ([name isEqualToString: @"Medical"]) {
        return @"医疗";
    }else if ([name isEqualToString: @"Catalogs"]) {
        return @"商品指南";
    }else if ([name isEqualToString: @"FoodDrink"]) {
        return @"美食";
    }else if ([name isEqualToString: @"Game"]) {
        return @"游戏";
    }
    
    return nil;
}


+(UILabel *)createLabelFrame:(CGRect)frame title:(NSString *)title
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.text = title;
    return label;
}

+(UIButton *)createBtnFrame:(CGRect)frame type:(UIButtonType)type bgImageName:(NSString *)bgImageName title:(NSString *)title target:(id)target action:(SEL)action
{
    UIButton *btn = [UIButton buttonWithType:type];
    btn.frame = frame;
    [btn setBackgroundImage:[UIImage imageNamed:bgImageName] forState:UIControlStateNormal];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

+(UIImageView *)createImageViewFrame:(CGRect)frame imageName:(NSString *)imageName
{
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:frame];
    imgView.image = [UIImage imageNamed:imageName];
    return imgView;
}

@end











