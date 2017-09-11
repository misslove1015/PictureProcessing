//
//  DrawView.h
//  PictureProcessing
//
//  Created by miss on 2017/9/8.
//  Copyright © 2017年 mukr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DrawView : UIView

@property (nonatomic, assign) NSInteger lineWidth;
@property (nonatomic, strong) UIColor *lineColor;

- (void)reset;
- (void)back;

@end
