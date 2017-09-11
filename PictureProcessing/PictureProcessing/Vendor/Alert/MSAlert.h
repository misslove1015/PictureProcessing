//
//  MSAlert.h
//  Miss
//
//  Created by miss on 2017/5/9.
//  Copyright © 2017年 mukr. All rights reserved.
//

// 提示框

#import <Foundation/Foundation.h>

@interface MSAlert : NSObject

+ (void)showAlertWithTitle:(NSString *)title;

+ (void)showAlertWithTitle:(NSString*)title message:(NSString*)message;

+ (void)showAlertWithTitle:(NSString*)title message:(NSString*)message confirmButtonAction:(void(^)())confirmAction;

@end
