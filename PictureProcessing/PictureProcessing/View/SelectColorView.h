//
//  SelectColorView.h
//  PictureProcessing
//
//  Created by miss on 2017/9/8.
//  Copyright © 2017年 mukr. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^selectColorFinishBlock)(UIColor *color);

@interface SelectColorView : UIView

@property (nonatomic, strong) UIColor *currentColor;
@property (nonatomic, copy) selectColorFinishBlock selectColorBlock;

- (void)selectColorFinish:(selectColorFinishBlock)block;

@end
