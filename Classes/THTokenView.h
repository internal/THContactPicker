//
//  THtokenView.h
//  tokenEdit
//
//  Created by Tristan Himmelman on 11/2/12.
//  Copyright (c) 2012 Tristan Himmelman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "THTokenViewStyle.h"

@class THTokenView;
@class THEditTextField;

@protocol THTokenViewDelegate <NSObject>

- (void)tokenViewWasSelected:(THTokenView *)tokenView;
- (void)tokenViewWasUnSelected:(THTokenView *)tokenView;
- (void)tokenViewShouldBeRemoved:(THTokenView *)tokenView;

@end

@interface THTokenView : UIView <UITextInputTraits>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) THEditTextField *textField; // used to capture keyboard touches when view is selected
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) BOOL showComma;
@property (nonatomic, assign) CGFloat maxWidth;
@property (nonatomic, assign) CGFloat minWidth;
@property (nonatomic, assign) id <THTokenViewDelegate>delegate;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@property (nonatomic, strong) THTokenViewStyle *style;
@property (nonatomic, strong) THTokenViewStyle *selectedStyle;

- (id)initWithName:(NSString *)name;
- (id)initWithName:(NSString *)name style:(THTokenViewStyle *)style selectedStyle:(THTokenViewStyle *)selectedStyle;
- (id)initWithName:(NSString *)name style:(THTokenViewStyle *)style selectedStyle:(THTokenViewStyle *)selectedStyle showComma:(BOOL)showComma;

- (void)select;
- (void)unSelect;
- (void)setFont:(UIFont *)font;

@end
