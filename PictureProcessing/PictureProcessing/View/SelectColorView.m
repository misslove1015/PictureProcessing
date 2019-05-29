//
//  SelectColorView.m
//  PictureProcessing
//
//  Created by miss on 2017/9/8.
//  Copyright © 2017年 mukr. All rights reserved.
//

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#import "SelectColorView.h"
#import "UIView+ColorAtPoint.h"

@interface SelectColorView ()

@property (weak, nonatomic) IBOutlet UIView *gradientView;
@property (weak, nonatomic) IBOutlet UIView *gridView;
@property (weak, nonatomic) IBOutlet UIView *previewColorView;
@property (weak, nonatomic) IBOutlet UITextField *RTextField;
@property (weak, nonatomic) IBOutlet UITextField *GTextField;
@property (weak, nonatomic) IBOutlet UITextField *BTextField;

@property (nonatomic, strong) NSArray *colorArray;

@end

@implementation SelectColorView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        NSArray *nibView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
        UIView *view = [nibView objectAtIndex:0];
        view.frame = frame;
        self = (SelectColorView *)view;
        [self addGradient];
        [self addBorder];
    }
    return self;
}

- (void)addBorder {
    self.previewColorView.layer.borderWidth = self.gridView.layer.borderWidth = 1;
    self.previewColorView.layer.borderColor = self.gridView.layer.borderColor = [UIColor grayColor].CGColor;
}

- (void)selectColorFinish:(selectColorFinishBlock)block {
    self.selectColorBlock = block;
}

- (IBAction)cancelOrConfirmButtonClick:(UIButton *)sender {
    [self removeFromSuperview];
    if (sender.tag) {
        if (self.selectColorBlock) {
            self.selectColorBlock(self.previewColorView.backgroundColor);
        }
    }else {
        return;
    }
}

- (void)addGradient{
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)[UIColor redColor].CGColor,
                             (__bridge id)[UIColor yellowColor].CGColor,
                             (__bridge id)[UIColor greenColor].CGColor,
                             (__bridge id)[UIColor cyanColor].CGColor,
                             (__bridge id)[UIColor blueColor].CGColor,
                             (__bridge id)[UIColor purpleColor].CGColor,];
    gradientLayer.locations = @[@0, @0.2, @0.4, @0.6, @0.8, @1.0];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(0, 1.0);
    gradientLayer.frame = CGRectMake(0, 0, (self.frame.size.width-20)/2, self.frame.size.width-20);
    [self.gradientView.layer addSublayer:gradientLayer];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.superview endEditing:YES];
    [self getColorWithTouch:[touches anyObject]];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self getColorWithTouch:[touches anyObject]];
}

- (void)getColorWithTouch:(UITouch *)touch {
    CGPoint point = [touch locationInView:self.gradientView];
    CGFloat width = (self.frame.size.width-20)/2;
    CGFloat height = self.frame.size.width-20;
    if (point.x < 0 || point.x > width || point.y < 0|| point.y > height) {
        return;
    }
    UIColor *color = [self.gradientView colorOfPoint:point];
    [self updateColor:color];
}

- (IBAction)gridButtonClick:(UIButton *)sender {
    [self updateColor:self.colorArray[sender.tag]];
}

- (void)updateColor:(UIColor *)color {
    self.previewColorView.backgroundColor = color;
    
    CGFloat components[3];
    [self getRGBComponents:components forColor:color];
    self.RTextField.text = [NSString stringWithFormat:@"%.0f",components[0]*255];
    self.GTextField.text = [NSString stringWithFormat:@"%.0f",components[1]*255];
    self.BTextField.text = [NSString stringWithFormat:@"%.0f",components[2]*255];
}

- (void)getRGBComponents:(CGFloat [3])components forColor:(UIColor *)color {
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char resultingPixel[4];
    CGContextRef context = CGBitmapContextCreate(&resultingPixel,
                                                 
                                                 1,
                                                 
                                                 1,
                                                 
                                                 8,
                                                 
                                                 4,
                                                 
                                                 rgbColorSpace,
                                                 
                                                 (CGBitmapInfo)kCGImageAlphaNoneSkipLast);
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
    CGContextRelease(context);
    CGColorSpaceRelease(rgbColorSpace);
    for (int component = 0; component < 3; component++) {
        components[component] = resultingPixel[component] / 255.0f;
    }
    
}

- (IBAction)editingEnd:(id)sender {
    CGFloat r = [self.RTextField.text integerValue]/255.0;
    CGFloat g = [self.GTextField.text integerValue]/255.0;
    CGFloat b = [self.BTextField.text integerValue]/255.0;
    UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:1];
    [self updateColor:color];
}

- (NSArray *)colorArray {
    if (!_colorArray) {
        _colorArray = @[[UIColor whiteColor],
                        [UIColor blueColor],
                        [UIColor greenColor],
                        [UIColor redColor],
                        [UIColor yellowColor],
                        [UIColor purpleColor],
                        [UIColor brownColor],
                        [UIColor orangeColor],
                        [UIColor blackColor]];
    }
    return _colorArray;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
