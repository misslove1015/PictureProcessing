//
//  DrawView.m
//  PictureProcessing
//
//  Created by miss on 2017/9/8.
//  Copyright © 2017年 mukr. All rights reserved.
//

#import "DrawView.h"

@interface DrawView ()

@property (nonatomic, strong) UIBezierPath *path; 
@property (nonatomic, strong) NSMutableArray *lineArray;
@property (nonatomic, strong) NSMutableArray *colorArray;

@end

@implementation DrawView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.lineWidth = 5;
        self.lineColor = [UIColor blackColor];
    }
    return self;
}

- (void)reset {
    [self.lineArray removeAllObjects];
    [self.colorArray removeAllObjects];
    [self setNeedsDisplay];
}

- (void)back {
    if (self.lineArray.count > 0) {
        [self.lineArray removeLastObject];
        [self.colorArray removeLastObject];
        [self setNeedsDisplay];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    self.path = [UIBezierPath bezierPath];
    self.path.lineWidth = self.lineWidth;
    [self.path moveToPoint:[touch locationInView:self]];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    [self.path addLineToPoint:[touch locationInView:self]];
    [self setNeedsDisplay];

}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    [self.path addLineToPoint:[touch locationInView:self]];
    [self setNeedsDisplay];
    [self.lineArray addObject:self.path];
    [self.colorArray addObject:self.lineColor];
    self.path = nil;
}


- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
}

- (void)drawRect:(CGRect)rect {
    for (NSInteger i = 0; i < self.lineArray.count; i++) {
        UIColor *color = self.colorArray[i];
        [color setStroke];
        UIBezierPath *path = self.lineArray[i];
        path.lineCapStyle = kCGLineCapRound;
        [path stroke];
    }
    [self.lineColor setStroke];
    self.path.lineCapStyle = kCGLineCapRound;
    [self.path stroke];
}

- (NSMutableArray *)lineArray {
    if (!_lineArray) {
        _lineArray = [[NSMutableArray alloc]init];        
    }
    return _lineArray;
}

- (NSMutableArray *)colorArray {
    if (!_colorArray) {
        _colorArray = [[NSMutableArray alloc]init];
    }
    return _colorArray;
}

@end
