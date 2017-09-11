//
//  MoveTextField.m
//  PictureProcessing
//
//  Created by miss on 2017/9/8.
//  Copyright © 2017年 mukr. All rights reserved.
//

#import "MoveTextField.h"

@interface MoveTextField () {
    CGPoint startPoint;
}

@end

@implementation MoveTextField


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.borderStyle = UITextBorderStyleNone;
    CGPoint point = [[touches anyObject] locationInView:self];
    startPoint = point;
    [[self superview] bringSubviewToFront:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint point = [[touches anyObject] locationInView:self];
    float dx = point.x - startPoint.x;
    float dy = point.y - startPoint.y;
    //计算移动后的view中心点
    CGPoint newcenter = CGPointMake(self.center.x + dx, self.center.y + dy);
    //移动view
    self.center = newcenter;
    
//    /* 限制用户不可将视图托出屏幕 */
//    float halfx = CGRectGetMidX(self.bounds);
//    //x坐标左边界
//    newcenter.x = MAX(halfx, newcenter.x);
//    //x坐标右边界
//    newcenter.x = MIN(self.superview.bounds.size.width - halfx, newcenter.x);
//    
//    //y坐标同理
//    float halfy = CGRectGetMidY(self.bounds);
//    newcenter.y = MAX(halfy, newcenter.y);
//    newcenter.y = MIN(self.superview.bounds.size.height - halfy, newcenter.y);    

}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.borderStyle = UITextBorderStyleNone;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
