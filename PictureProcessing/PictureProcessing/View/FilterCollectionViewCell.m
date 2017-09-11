//
//  FilterCollectionViewCell.m
//  PictureProcessing
//
//  Created by miss on 2017/9/8.
//  Copyright © 2017年 mukr. All rights reserved.
//

#import "FilterCollectionViewCell.h"

@implementation FilterCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.contentView.layer.borderColor = [UIColor blueColor].CGColor;
}

- (void)addBorder {
    self.contentView.layer.borderWidth = 1.5;
}

- (void)removeBorder {
    self.contentView.layer.borderWidth = 0;
}

@end
