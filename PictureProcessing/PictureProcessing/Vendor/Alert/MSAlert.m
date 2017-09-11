//
//  MSAlert.m
//  Miss
//
//  Created by miss on 2017/5/9.
//  Copyright © 2017年 mukr. All rights reserved.
//

#import "MSAlert.h"
#import <UIKit/UIKit.h>

@implementation MSAlert

+ (void)showAlertWithTitle:(NSString *)title {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert];
}

+ (void)showAlertWithTitle:(NSString*)title message:(NSString*)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert];
}

+ (void)showAlertWithTitle:(NSString*)title message:(NSString*)message confirmButtonAction:(void(^)())confirmAction {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
        if (action) {
            confirmAction();
        }
    }]];
    [self presentViewController:alert];
}

+ (void)presentViewController:(UIViewController*)controller {
    UIViewController* rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    [rootViewController presentViewController:controller animated:YES completion:nil];
}

@end
