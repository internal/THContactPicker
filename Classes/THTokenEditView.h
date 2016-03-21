//
//  TokenEditTextView.h
//  TokenEdit
//
//  Created by Tristan Himmelman on 11/2/12.
//  Copyright (c) 2012 Tristan Himmelman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THTokenView.h"

@class THTokenEditView;

@protocol THTokenEditDelegate <NSObject>

@optional
- (void)tokenEditDidResize:(THTokenEditView *)tokenEdit;
- (void)tokenEdit:(THTokenEditView *)tokenEdit didSelectToken:(id)token;
- (void)tokenEdit:(THTokenEditView *)tokenEdit didRemoveToken:(id)token;
- (void)tokenEdit:(THTokenEditView *)tokenEdit textFieldDidBeginEditing:(UITextField *)textField;
- (void)tokenEdit:(THTokenEditView *)tokenEdit textFieldDidEndEditing:(UITextField *)textField;
- (BOOL)tokenEdit:(THTokenEditView *)tokenEdit textFieldShouldReturn:(UITextField *)textField;
- (void)tokenEdit:(THTokenEditView *)tokenEdit textFieldDidChange:(UITextField *)textField;

@end

@interface THTokenEditView : UIView <UITextViewDelegate, THTokenViewDelegate, UIScrollViewDelegate, UITextInputTraits>

@property (nonatomic, strong) THTokenView *selectedTokenView;
@property (nonatomic, assign) IBOutlet id <THTokenEditDelegate>delegate;

@property (nonatomic, assign) BOOL limitToOne;				// only allow the TokenEdit to add one token
@property (nonatomic, assign) CGFloat verticalPadding;		// amount of padding above and below each token view
@property (nonatomic, assign) NSInteger maxNumberOfLines;	// maximum number of lines the view will display before scrolling
@property (nonatomic, strong) UIFont *font;

- (void)addToken:(id)token withName:(NSString *)name;
- (void)addToken:(id)token withName:(NSString *)name withStyle:(THTokenViewStyle*)bubbleStyle andSelectedStyle:(THTokenViewStyle*) selectedStyle;
- (void)removeToken:(id)token;
- (void)removeAllTokens;
- (BOOL)resignFirstResponder;

// View Customization
- (void)setTokenViewStyle:(THTokenViewStyle *)color selectedStyle:(THTokenViewStyle *)selectedColor;
- (void)setPlaceholderLabelText:(NSString *)text;
- (void)setPlaceholderLabelTextColor:(UIColor *)color;
- (void)setPromptLabelText:(NSString *)text;
- (void)setPromptLabelAttributedText:(NSAttributedString *)attributedText;
- (void)setPromptLabelTextColor:(UIColor *)color;
- (void)setPromptTintColor:(UIColor *)color;
- (void)setFont:(UIFont *)font;

@end
