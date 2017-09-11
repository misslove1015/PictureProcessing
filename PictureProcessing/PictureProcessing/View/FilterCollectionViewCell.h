//
//  FilterCollectionViewCell.h
//  PictureProcessing
//
//  Created by miss on 2017/9/8.
//  Copyright © 2017年 mukr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *filterLabel;

- (void)addBorder;
- (void)removeBorder;

@end
