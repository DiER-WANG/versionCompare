//
//  ViewController.m
//  VersionCompare
//
//  Created by wangchangyang on 2017/3/3.
//  Copyright © 2017年 wangchangyang. All rights reserved.
//

#import "ViewController.h"

typedef NS_ENUM(NSInteger, VersionConpareResult) {
    VersionConpareResultSecond = -1, // 第二个版本高
    VersionConpareResultEqual,       // 两个版本相同
    VersionConpareResultFirst        // 第一个版本相同
};

typedef void(^VersionCompareBlock)(VersionConpareResult);
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSArray *testArr
    = @[
        @[@"11", @"12"],// -1
        @[@"12", @"11"],// 1
        @[@"11", @"11"], // 0
        @[@"1.1.1", @"1.2.1"],// -1
        @[@"1.2.1", @"1.1.1"]// 1
    ];
    
    for (NSArray *arr in testArr) {
        [self version:arr.firstObject compare:arr.lastObject withResult:^(VersionConpareResult result) {
            NSLog(@"%@", @(result));
        }];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/**
 版本比较
 版本号规则： xx.xxx.xx
 @param version1 版本 1
 @param version2 版本 2
 @param block 比较结果回调, 1: 表示 v1 版本高， 0 表示版本相同，-1 表示版本 v2 高
 */
- (void)version:(NSString *)version1 compare:(NSString *)version2 withResult:(VersionCompareBlock)block {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       
        VersionConpareResult compareResult;
        // 1、先比较位数，用字符串分割
        NSArray *v1Arr = [version1 componentsSeparatedByString:@"."];
        NSArray *v2Arr = [version2 componentsSeparatedByString:@"."];
        
        compareResult = (v1Arr.count - v2Arr.count);
        
        if (compareResult > 0) {
            compareResult = VersionConpareResultFirst;
        } else if (compareResult < 0) {
            compareResult = VersionConpareResultSecond;
        }
        
        if (compareResult != 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(compareResult);
            });
            return;
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
        dispatch_async(dispatch_get_main_queue(), ^{
           block(compareResult);
        });
    });
}


@end
