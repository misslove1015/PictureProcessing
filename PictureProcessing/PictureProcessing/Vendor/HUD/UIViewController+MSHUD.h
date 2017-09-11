//
//  UIViewController+MSHUD.h
//  Miss
//
//  Created by miss on 2017/4/28.
//  Copyright © 2017年 mukr. All rights reserved.
//

// HUD提示层

#import <UIKit/UIKit.h>

@interface UIViewController (MSHUD)

- (void)showTextHUD:(NSString *)text;
- (void)showTextHUDAtWindow:(NSString *)text;

- (void)showLoadingHUD;
- (void)hideLoadingHUD;

@end
