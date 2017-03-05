//
//  ViewController.m
//  VersionCompare
//
//  Created by wangchangyang on 2017/3/3.
//  Copyright © 2017年 wangchangyang. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@end

@implementation ViewController

typedef NS_ENUM(NSInteger, VersionCompareResult) {
    VersionCompareFormatError = -1000,
    VersionConpareResultSecond = -1, // 第二个版本高
    VersionConpareResultEqual,       // 两个版本相同
    VersionConpareResultFirst        // 第一个版本相同
};
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSArray *testArr
    = @[
        @[@"11", @"12"],// -1
        @[@"12", @"11"],// 1
        @[@"11", @"11"], // 0
        @[@"1.1.1", @"1.2.1"],// -1
        @[@"1.2.1", @"1.1.1"],// 1
        @[@"1.2.1", @"1.1.a"]//- 1000
    ];
    for (NSArray *arr in testArr) {
        NSLog(@"%@", @([self version:arr.firstObject compare:arr.lastObject]));
    }
}
/**
 版本比较 版本号存在的小数点越多表示的版本号越大
 版本号规则： xx.xxx.xx
 @param     version1 版本 1
 @param     version2 版本 2
 @return    VersionConpareResultSecond = -1, // 第二个版本高
            VersionConpareResultEqual,       // 两个版本相同
            VersionConpareResultFirst        // 第一个版本相同
 */
- (VersionCompareResult)version:(NSString *)version1 compare:(NSString *)version2 {
    
    VersionCompareResult compareResult;
    
    if (version1 == nil || version2 == nil) {
        return VersionCompareFormatError;
    }
    
    // 1、先比较位数，用字符串分割
    NSArray *v1Arr = [version1 componentsSeparatedByString:@"."];
    NSArray *v2Arr = [version2 componentsSeparatedByString:@"."];
    
    // 2、只包含数字
    NSString *regx = @"^[0-9]+$";
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regx];
    BOOL isError = NO;
    for (NSString *test1 in v1Arr) {
        if (![pre evaluateWithObject:test1]) {
            isError = YES;
            break;
        }
    }
    for (NSString *test2 in v2Arr) {
        if (![pre evaluateWithObject:test2]) {
            isError = YES;
            break;
        }
    }
    if (isError) {
        return VersionCompareFormatError;
    }
    
    compareResult = (v1Arr.count - v2Arr.count);
    
    if (compareResult > 0) {
        compareResult = VersionConpareResultFirst;
    } else if (compareResult < 0) {
        compareResult = VersionConpareResultSecond;
    }
    
    if (compareResult != 0) {
        return compareResult;
    }
    
    NSInteger count = v1Arr.count;
    for (NSInteger i = 0; i < count; i++) {
        NSString *v1 = v1Arr[i];
        NSString *v2 = v2Arr[i];
        NSComparisonResult rst = [v1 compare:v2];
        if (rst != NSOrderedSame) {
            if (rst == NSOrderedAscending) {
                compareResult = VersionConpareResultSecond;
            } else {
                compareResult = VersionConpareResultFirst;
            }
            break;
        }
        if (i == (count - 1)) {
            compareResult = VersionConpareResultEqual;
        }
    }
    return compareResult;
}


@end
