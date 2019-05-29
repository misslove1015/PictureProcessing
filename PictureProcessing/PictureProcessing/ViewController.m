//
//  ViewController.m
//  PictureProcessing
//
//  Created by miss on 2017/9/8.
//  Copyright © 2017年 mukr. All rights reserved.
//

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#import "ViewController.h"
#import "DrawView.h"
#import "LineWidthCell.h"
#import "UIView+ColorAtPoint.h"
#import "SelectColorView.h"
#import "UIViewController+MSHUD.h"
#import "MSAlert.h"
#import <objc/runtime.h>
#import "MoveTextField.h"
#import "FilterCollectionViewCell.h"
#import "FWApplyFilter.h"
#import "LWImageCropView.h"

@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource> {
    BOOL filterIsSelect[20];
    BOOL enchanceIsSelect[10];
}

@property (weak, nonatomic) IBOutlet UIButton           *resetButton; // 重置按钮
@property (weak, nonatomic) IBOutlet UIView             *editView; // 画布view
@property (weak, nonatomic) IBOutlet UIView             *brushView; // 画笔view
@property (weak, nonatomic) IBOutlet UIScrollView       *brushSizeScrollView; // 画笔大小ScrollView
@property (weak, nonatomic) IBOutlet UIScrollView       *brushColorScrollView; // 画笔颜色ScrollView
@property (weak, nonatomic) IBOutlet UIView             *brush; // 当前画笔
@property (weak, nonatomic) IBOutlet UITextField        *brushSizeTextField; // 画笔大小文本框
@property (weak, nonatomic) IBOutlet UIBarButtonItem    *addPhotoItem; // 添加照片item
@property (weak, nonatomic) IBOutlet UIView             *filterView; // 滤镜view
@property (weak, nonatomic) IBOutlet UIView             *enhanceView; // 增强view
@property (weak, nonatomic) IBOutlet UISlider           *slider; // 增强slider
@property (weak, nonatomic) IBOutlet UILabel            *sliderValueLabel; // slider当前value Label
@property (weak, nonatomic) IBOutlet LWImageCropView    *cropView; // 裁剪view
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *brushWidth; // 当前画笔大小
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *brushBottomSpace; // 画笔view距底部距离
@property (weak, nonatomic) IBOutlet UIButton *cropButton;

@property (nonatomic, strong) UIImage          *originalImage; // 原始图片
@property (nonatomic, strong) DrawView         *drawView; // 画布viw
@property (nonatomic, strong) NSArray          *brushColorArray; // 画笔颜色数组
@property (nonatomic, strong) NSArray          *brushSizeArray; // 画笔大小数组
@property (nonatomic, assign) BOOL             keyboardIsShow; // 键盘是否弹出
@property (nonatomic, strong) UIImageView      *imageView; // 当前正在编辑的图片
@property (nonatomic, strong) NSMutableArray   *textFieldArray; // 文本框数组
@property (nonatomic, strong) NSArray          *filterArray; // 滤镜数组
@property (nonatomic, strong) NSArray          *enhanceArray; // 增强效果数组
@property (nonatomic, assign) NSInteger        enchanceIndex; // 当前选择的增强类型
@property (nonatomic, strong) UICollectionView *filterCollectionView; // 滤镜CollectionView
@property (nonatomic, strong) UICollectionView *enhanceCollectionView; // 增强CollectionView

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    [self addView];
    [self setBrush];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
   
}

// 添加画布View
- (void)addView {
    [self.editView addSubview:self.drawView];
}

// 设置画笔大小、颜色view
- (void)setBrush {
    self.brushSizeScrollView.contentSize = CGSizeMake(10+(30+10)*8, 40);
    
    for (NSInteger i = 0; i < 8; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(10+(30+10)*i, 5, 30, 30);
        [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"size-%ld",[self.brushSizeArray[i] integerValue]]] forState:UIControlStateNormal];
        button.tag = i;
        [button addTarget:self action:@selector(updateBrushSize:) forControlEvents:UIControlEventTouchUpInside];
        [self.brushSizeScrollView addSubview:button];
    }
    
    self.brushColorScrollView.contentSize = CGSizeMake(10+(30+10)*7, 40);
    
    for (NSInteger i = 0; i < 7; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(10+(30+10)*i, 5, 30, 30);
        button.backgroundColor = self.brushColorArray[i];
        [button addTarget:self action:@selector(updateBrushColor:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = i;
        [self.brushColorScrollView addSubview:button];
        button.layer.cornerRadius = 3;
        if (i == 0 || i==6) {
            button.layer.borderWidth = 0.5;
            button.layer.borderColor = [UIColor lightGrayColor].CGColor;
        }
        if (i == 6) {
            [button setTitle:@"+" forState:UIControlStateNormal];
            [button setTitleEdgeInsets:UIEdgeInsetsMake(-4, 0, 0, 0)];
            [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:28];
        }
    }
    
    self.brush.layer.cornerRadius = 2.5;
    self.brush.layer.borderWidth = 0;
    self.brush.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

- (void)keyboardChangeFrame:(NSNotification *)noti{
    NSInteger curve = [[noti.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    CGFloat duration = [[noti.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect endFrame = [[noti.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if (endFrame.origin.y >= SCREEN_HEIGHT) {
        self.brushBottomSpace.constant = 50;
        self.keyboardIsShow = NO;
        self.drawView.userInteractionEnabled = YES;
    }else {
        self.brushBottomSpace.constant = SCREEN_HEIGHT-endFrame.origin.y-BOTTOM_HEIGHT;
        self.keyboardIsShow = YES;
        self.drawView.userInteractionEnabled = NO;
    }
    [UIView animateWithDuration:duration animations:^{
        [UIView setAnimationCurve:curve];
        [self.view layoutIfNeeded];
    }];
    
}

// 画笔大小按钮点击
- (void)updateBrushSize:(UIButton *)button {
    NSInteger width = [self.brushSizeArray[button.tag] integerValue];
    [self setBrushSize:width];
}

// 设置画笔的粗细和文字的大小
- (void)setBrushSize:(NSInteger)width {
    
    for (MoveTextField *textField in self.textFieldArray) {
        textField.font = [UIFont systemFontOfSize:width];;
    }
    
    if (width > 40) width = 40;
    if (width < 1) width = 1;
    
    self.brushWidth.constant = width;
    self.brush.layer.cornerRadius = width/2;
    self.brushSizeTextField.text = [NSString stringWithFormat:@"%ld",width];
    self.drawView.lineWidth = width;
}

// 画笔颜色按钮点击
- (void)updateBrushColor:(UIButton *)button {
    if (button.tag == 6) {
        SelectColorView *colorView = [[SelectColorView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        __weak typeof(self) weakSelf = self;
        [colorView selectColorFinish:^(UIColor *color) {
            [weakSelf setBrushColor:color];
        }];
        [self.view addSubview:colorView];
        return;
    }
    
    UIColor *color = self.brushColorArray[button.tag];
    [self setBrushColor:color];
    
}

// 设置画笔颜色
- (void)setBrushColor:(UIColor *)color{
    self.brush.backgroundColor = color;
    self.drawView.lineColor = color;
    
    CGFloat components[3];
    [self getRGBComponents:components forColor:color];
    if (components[0] > 0.9 && components[1] > 0.9 && components[2] > 0.9) {
        self.brush.layer.borderWidth = 1;
    }else {
        self.brush.layer.borderWidth = 0;
    }
    
    for (MoveTextField *textField in self.textFieldArray) {
        textField.textColor = color;
    }
}

// 将颜色转为RGB数值
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


// 画笔按钮
- (IBAction)brushButtonClick:(UIButton *)sender {
    self.filterView.hidden = YES;
    self.enhanceView.hidden = YES;
}

// 增强按钮
- (IBAction)enhanceButtonClick:(id)sender {
    if (!self.imageView) {
        [self showNoPic];
        return;
    }
    self.enhanceView.hidden = NO;
    self.filterView.hidden = YES;
    [self.enhanceView addSubview:self.enhanceCollectionView];
}

// 文字按钮
- (IBAction)characterButtonClick:(id)sender {
    self.filterView.hidden = YES;
    self.enhanceView.hidden = YES;
    
    MoveTextField *textField = [[MoveTextField alloc]initWithFrame:CGRectMake(50, 50, SCREEN_WIDTH, 60)];
    textField.textColor = self.brush.backgroundColor;
    textField.borderStyle = UITextBorderStyleNone;
    textField.font = [UIFont systemFontOfSize:30];
    [textField becomeFirstResponder];
    if (self.imageView) {
        [self.imageView addSubview:textField];
    }else {
        [self.editView addSubview:textField];
    }
    [textField addTarget:self action:@selector(moveTextFieldEditingEnd:) forControlEvents:UIControlEventEditingDidEnd];
    
    [self.textFieldArray addObject:textField];
    
}

// 如果文本框内已没有文字，删除该文本框
- (void)moveTextFieldEditingEnd:(UITextField *)textField {
    if (textField.text.length == 0) {
        [textField removeFromSuperview];
    }
}

// 滤镜按钮
- (IBAction)filterButtonClick:(id)sender {
    if (!self.imageView) {
        [self showNoPic];
        return;
    }
    self.filterView.hidden = NO;
    self.enhanceView.hidden = YES;
    [self.filterView addSubview:self.filterCollectionView];
}

// 裁剪按钮
- (IBAction)crop:(UIButton *)sender {
    if (!self.imageView) {
        [self showNoPic];
        return;
    }
    sender.selected = !sender.selected;
    if (sender.isSelected) {
        self.cropView.hidden = NO;
        [self.editView bringSubviewToFront:self.cropView];
        [self.cropView setImage:self.imageView.image];
    }else {
        self.cropView.hidden = YES;
    }
    
}

- (void)showNoPic {
    [self showTextHUD:@"当前画布上没有图片"];
}

// 重置按钮
- (IBAction)reset:(id)sender {
    [self.drawView reset];
}

// 后退按钮
- (IBAction)back:(id)sender {
    [self.drawView back];
}

// 恢复按钮
- (IBAction)recover:(id)sender {
    self.imageView.image = self.originalImage;
    self.slider.value = 0.5;
    self.sliderValueLabel.text = 0;
}

// 吸管按钮
- (IBAction)suckerButtonClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.isSelected) {
        self.drawView.userInteractionEnabled = NO;
        self.imageView.userInteractionEnabled = NO;
    }else {
        self.drawView.userInteractionEnabled = YES;
        self.imageView.userInteractionEnabled = YES;
    }
}

// 吸管状态下，点击屏幕获取当前位置处的颜色
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.keyboardIsShow) {
        [self.view endEditing:YES];
        return;
    }
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.editView];

    UIColor *color = [self.editView colorOfPoint:point];
    [self setBrushColor:color];
}

// 画笔/字体大小文本框编辑结束
- (IBAction)brushSizeEditingEnd:(UITextField *)sender {
    NSInteger width = sender.text.integerValue;
    [self setBrushSize:width];
    
}

// 从图片上裁切指定大小的图片
- (UIImage *)cropImageFromView:(UIImage *)image rect:(CGRect)rect {
    CGImageRef newImageRef = CGImageCreateWithImageInRect(image.CGImage, rect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    CGImageRelease(newImageRef);
    return newImage;
    
}

/**
 * 存储按钮
 * 1.在裁切图片时，将裁切过的图片放在画布上
 * 2.在处理图片时，将处理后的时保存至相册
 * 3.在画布情况下，将画布截屏并保存至相册
 */
- (IBAction)save:(id)sender {
    if (!self.cropView.isHidden) {
        UIImage *image = [self cropImageFromView:self.originalImage rect:self.cropView.cropAreaInImage];
        self.cropView.hidden = YES;
        self.cropButton.selected = NO;
        CGFloat superViewWidth = self.editView.frame.size.width;
        CGFloat superViewHeight = self.editView.frame.size.height;
        CGFloat imageWidth = image.size.width;
        CGFloat imageHeight = image.size.height;
        self.imageView.image = image;
        self.imageView.contentMode = UIViewContentModeScaleToFill;
        CGFloat height = superViewWidth*imageHeight/imageWidth;
        self.imageView.bounds = CGRectMake(0, 0, superViewWidth, height);
        if (height > superViewHeight) {
            CGFloat width = superViewHeight*imageWidth/imageHeight;
            self.imageView.bounds = CGRectMake(0, 0, width, superViewHeight);
        }
        self.imageView.center = CGPointMake(self.editView.frame.size.width/2, self.editView.frame.size.height/2);
        self.originalImage = self.imageView.image;
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage *image;
        if (self.imageView) {
            image = [self getImageFromView:self.imageView];
        }else {
            image = [self getImageFromView:self.editView];
        }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);

    });
    
    [self showTextHUD:@"已保存"];
}

// 将view截屏
- (UIImage *)getImageFromView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(view.frame.size.width, view.frame.size.height), NO, [UIScreen mainScreen].scale);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

/**
 * 添加照片按钮
 * 如果画布上已有照片，则会改为删除按钮
 *
 */
- (IBAction)getPhoto:(UIBarButtonItem *)sender {
    if (self.imageView){
        [MSAlert showAlertWithTitle:@"确定丢弃图片？" message:nil confirmButtonAction:^{
            self.cropView.hidden = YES;
            self.cropButton.selected = NO;
            [self.imageView removeFromSuperview];
            [self.drawView removeFromSuperview];
            [self.drawView reset];
            self.imageView = nil;
            UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(getPhoto:)];
            self.navigationItem.leftBarButtonItem = item;
            self.drawView.frame = self.editView.bounds;
            [self.editView addSubview:self.drawView];
            self.editView.backgroundColor = [UIColor whiteColor];
        }];
    }else {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        //判断类型：手机中所有图片
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            picker.delegate = self;
        }
        
        [self presentViewController:picker animated:YES completion:nil];
    }

}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"]){
        
        UIImage *image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
        if (!image){
            image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        }
        [self.drawView reset];
        [self.drawView removeFromSuperview];
        for (MoveTextField *textField in self.textFieldArray) {
            [textField removeFromSuperview];
        }
        [self.textFieldArray removeAllObjects];
        [self setImageViewImage:image];
        
        //self.addPhotoItem.style = UIBarButtonSystemItemTrash;
        // 获取一个类的所有属性
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

// 照片选择结束，将照片放在画布上
- (void)setImageViewImage:(UIImage *)image {
   self.originalImage = image;
    CGFloat superViewWidth = self.editView.frame.size.width;
    CGFloat superViewHeight = self.editView.frame.size.height;
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;
    self.imageView = [[UIImageView alloc]init];
    self.imageView.image = image;
    [self.editView addSubview:self.imageView];
    CGFloat height = superViewWidth*imageHeight/imageWidth;
    self.imageView.bounds = CGRectMake(0, 0, superViewWidth, height);
    if (height > superViewHeight) {
        CGFloat width = superViewHeight*imageWidth/imageHeight;
        self.imageView.bounds = CGRectMake(0, 0, width, superViewHeight);
    }
    self.imageView.center = CGPointMake(self.editView.frame.size.width/2, self.editView.frame.size.height/2);
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(getPhoto:)];
    self.navigationItem.leftBarButtonItem = item;
    self.editView.backgroundColor = [UIColor blackColor];
    self.drawView.frame = self.imageView.bounds;
    self.imageView.userInteractionEnabled = YES;
    [self.imageView addSubview:self.drawView];
}

// 滤镜和增强效果collectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == self.filterCollectionView) {
        return self.filterArray.count;

    }else {
        return self.enhanceArray.count;
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FilterCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor colorWithRed:130/255.0 green:0/255.0 blue:70/255.0 alpha:0.8];
    if (collectionView == self.filterCollectionView) {
        cell.filterLabel.text = self.filterArray[indexPath.item];
        if (filterIsSelect[indexPath.item]) {
            [cell addBorder];
        }else {
            [cell removeBorder];
        }
    }else {
        cell.filterLabel.text = self.enhanceArray[indexPath.item];
        if (enchanceIsSelect[indexPath.item]) {
            [cell addBorder];
        }else {
            [cell removeBorder];
        }
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.filterCollectionView) {
        [self addFilter:indexPath.item];
        memset(filterIsSelect, 0, sizeof(filterIsSelect));
        filterIsSelect[indexPath.item] = YES;
        [self.filterCollectionView reloadData];
    }else {
        self.slider.value = 0.5;
        self.sliderValueLabel.text = @"0";
        self.enchanceIndex = indexPath.row;
        memset(enchanceIsSelect, 0, sizeof(enchanceIsSelect));
        enchanceIsSelect[indexPath.item] = YES;
        [self.enhanceCollectionView reloadData];
    }
}

- (void)addFilter:(NSInteger)index {
    if (!self.originalImage) return;
    UIImage *filterImage;
    switch (index) {
        case 0:
            filterImage = self.originalImage;
            break;
            
        case 1:
            filterImage = [FWApplyFilter applyLomofiFilter:self.originalImage];
            break;
            
        case 2:
            filterImage = [FWApplyFilter applyLomo1Filter:self.originalImage];
            break;
            
        case 3:
            filterImage =[FWApplyFilter applyMissetikateFilter:self.originalImage];
            break;
            
        case 4:
            filterImage =[FWApplyFilter applyNashvilleFilter:self.originalImage];
            break;
            
        case 5:
            filterImage =[FWApplyFilter applyLordKelvinFilter:self.originalImage];
            break;
            
        case 6:
            filterImage = [FWApplyFilter applyAmatorkaFilter:self.originalImage];
            break;
            
        case 7:
            filterImage = [FWApplyFilter applyRiseFilter:self.originalImage];
            break;
            
        case 8:
            filterImage= [FWApplyFilter applyHudsonFilter:self.originalImage];
            break;
            
        case 9:
            filterImage = [FWApplyFilter applyXproIIFilter:self.originalImage];
            break;
            
        case 10:
            filterImage =[FWApplyFilter apply1977Filter:self.originalImage];
            break;
            
        case 11:
            filterImage =[FWApplyFilter applyValenciaFilter:self.originalImage];
            break;
            
        case 12:
            filterImage =[FWApplyFilter applyWaldenFilter:self.originalImage];
            break;
            
        case 13:
            filterImage = [FWApplyFilter applyLocalBinaryPatternFilter:self.originalImage];
            break;
            
        case 14:
            filterImage = [FWApplyFilter applyInkwellFilter:self.originalImage];
            break;
            
        case 15:
            filterImage= [FWApplyFilter applySierraFilter:self.originalImage];
            break;
            
        case 16:
            filterImage = [FWApplyFilter applyEarlybirdFilter:self.originalImage];
            break;
            
        case 17:
            filterImage =[FWApplyFilter applySutroFilter:self.originalImage];
            break;
            
        case 18:
            filterImage =[FWApplyFilter applyToasterFilter:self.originalImage];
            break;
            
        case 19:
            filterImage =[FWApplyFilter applyBrannanFilter:self.originalImage];
            break;
            
        case 20:
            filterImage = [FWApplyFilter applyHefeFilter:self.originalImage];
            break;
            
        default:
            break;
    }
    
    self.imageView.image = filterImage;
}


// 增强slider滑动
- (IBAction)sliderValueChanged:(UISlider *)sender {
    CGFloat value = sender.value;
    self.sliderValueLabel.text = [NSString stringWithFormat:@"%.0f",value*200-100];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self sliderValue:value];
    });
}

- (void)sliderValue:(CGFloat)value {
    switch (self.enchanceIndex) {
        case 0:{
            value -= 0.5;
            value *= 2;
            self.imageView.image = [FWApplyFilter changeValueForBrightnessFilter:value image:self.originalImage];
        }break;
        case 1:
            value *= 2;
            self.imageView.image = [FWApplyFilter changeValueForContrastFilter:value image:self.originalImage];
            break;
        case 2:
            value *= 2;
            self.imageView.image = [FWApplyFilter changeValueForSaturationFilter:value image:self.originalImage];
            break;
        case 3:
            self.imageView.image = [FWApplyFilter changeValueForHightlightFilter:value image:self.originalImage];
            break;
        case 4:
            self.imageView.image = [FWApplyFilter changeValueForLowlightFilter:value image:self.originalImage];
            break;
        case 5:
            value -= 0.5;
            value *= 2;
            self.imageView.image = [FWApplyFilter changeValueForExposureFilter:value image:self.originalImage];
            break;
        case 6:
            value *= 10000;
            
            self.imageView.image = [FWApplyFilter changeValueForWhiteBalanceFilter:value image:self.originalImage];
            break;
        case 7:
            value -= 0.5;
            value *= 2;
            
            self.imageView.image = [FWApplyFilter changeValueForVibranceFilter:value image:self.originalImage];
            break;
        case 8:
            value -= 0.5;
            value *= 2;
            
            self.imageView.image = [FWApplyFilter changeValueForSharpenilter:value image:self.originalImage];
            break;
        case 9:
            self.imageView.image = [FWApplyFilter autoBeautyFilter:self.originalImage];
            break;
            
        default:
            break;
    }

}

- (DrawView *)drawView {
    if (!_drawView) {
        _drawView = [[DrawView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64-40)];
        _drawView.backgroundColor = [UIColor clearColor];
    }
    return _drawView;
}

- (NSArray *)brushColorArray {
    if (!_brushColorArray) {
        _brushColorArray = @[[UIColor whiteColor],
                             [UIColor blackColor],
                             [UIColor redColor],
                             [UIColor blueColor],
                             [UIColor greenColor],
                             [UIColor lightGrayColor],
                             [UIColor whiteColor]];
    }
    return _brushColorArray;
}

- (NSArray *)brushSizeArray {
    if (!_brushSizeArray) {
        _brushSizeArray = @[@(2), @(5), @(8), @(10), @(12), @(15), @(20), @(30)];
    }
    return _brushSizeArray;
}

- (NSMutableArray *)textFieldArray {
    if (!_textFieldArray) {
        _textFieldArray = [[NSMutableArray alloc]init];
    }
    return _textFieldArray;
}

- (UICollectionView *)filterCollectionView {
    if (!_filterCollectionView) {
        memset(filterIsSelect, 0, sizeof(filterIsSelect));

        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.itemSize = CGSizeMake(50, 70);
        layout.sectionInset = UIEdgeInsetsMake(5, 10, 5, 10);
        layout.minimumInteritemSpacing = 10;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _filterCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0.5, SCREEN_WIDTH, 79) collectionViewLayout:layout];
        _filterCollectionView.delegate = self;
        _filterCollectionView.dataSource = self;
        _filterCollectionView.showsHorizontalScrollIndicator = NO;
        _filterCollectionView.backgroundColor = [UIColor whiteColor];
        [_filterCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([FilterCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:@"cell"];
    }
    return _filterCollectionView;
}

- (UICollectionView *)enhanceCollectionView {
    if (!_enhanceCollectionView) {
        memset(enchanceIsSelect, 0, sizeof(enchanceIsSelect));

        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.itemSize = CGSizeMake(35, 35);
        layout.sectionInset = UIEdgeInsetsMake(5, 10, 5, 10);
        layout.minimumInteritemSpacing = 10;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _enhanceCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 40, SCREEN_WIDTH, 35) collectionViewLayout:layout];
        _enhanceCollectionView.delegate = self;
        _enhanceCollectionView.dataSource = self;
        _enhanceCollectionView.showsHorizontalScrollIndicator = NO;
        _enhanceCollectionView.backgroundColor = [UIColor whiteColor];
        [_enhanceCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([FilterCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:@"cell"];
    }
    return _enhanceCollectionView;
}


- (NSArray *)filterArray {
    if (!_filterArray) {
        _filterArray = @[@"原图",
                         @"LOMO",
                         @"LOMO1",
                         @"Missetikate",
                         @"Nashville",
                         @"LordKelvin",
                         @"Amatorka",
                         @"Rise",
                         @"Hudson",
                         @"XproII",
                         @"1977",
                         @"Valencia",
                         @"Walden",
                         @"LocalBinaryPattern",
                         @"Inkwell",
                         @"Sierra",
                         @"Earlybird",
                         @"Sutro",
                         @"Toaster",
                         @"Brannan",
                         @"Hefe"];
    }
    return _filterArray;
}

- (NSArray *)enhanceArray {
    if (!_enhanceArray) {
        _enhanceArray = @[@"亮度",
                          @"对比度",
                          @"饱和度",
                          @"高光",
                          @"暗部",
                          @"智能补光",
                          @"色温",
                          @"自然饱和",
                          @"锐化",
                          @"智能优化"];
    }
    return _enhanceArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
