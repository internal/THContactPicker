//
//  THTokenEditView.m
//  THTokenEditView
//
//  Created by Tristan Himmelman on 11/2/12, revised by mysteriouss.
//  Copyright (c) 2012 Tristan Himmelman. All rights reserved.
//

#import "THTokenEditView.h"
#import "THTokenView.h"
#import "THEditTextField.h"

@interface THTokenEditView ()<THEditTextFieldDelegate>{
    BOOL _shouldSelectTextField;
	int _lineCount;
	CGRect _frameOfLastView;
	CGFloat _tokenHorizontalPadding;
	BOOL _showComma;
}

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableDictionary *tokens;	// Dictionary to store THTokenViews for each tokens
@property (nonatomic, strong) NSMutableArray *tokenKeys;      // an ordered set of the keys placed in the tokens dictionary
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, strong) UILabel *promptLabel;
@property (nonatomic, assign) CGFloat lineHeight;
@property (nonatomic, strong) THEditTextField *textField;
@property (nonatomic, strong) THTokenViewStyle *tokenViewStyle;
@property (nonatomic, strong) THTokenViewStyle *tokenViewSelectedStyle;

@end

@implementation THTokenEditView

#define kVerticalViewPadding				5   // the amount of padding on top and bottom of the view
#define kHorizontalPadding					0   // the amount of padding to the left and right of each token view
#define kHorizontalPaddingWithBackground	2   // the amount of padding to the left and right of each token view (when bubbles have a non white background)
#define kHorizontalSidePadding				10  // the amount of padding on the left and right of the view
#define kVerticalPadding					2   // amount of padding above and below each token view
#define kTextFieldMinWidth					20  // minimum width of trailing text view
#define KMaxNumberOfLinesDefault			2

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self){
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code        
        [self setup];
    }
    return self;
}

- (void)setup {
    self.verticalPadding = kVerticalViewPadding;
	self.maxNumberOfLines = KMaxNumberOfLinesDefault;
	
    self.tokens = [NSMutableDictionary dictionary];
    self.tokenKeys = [NSMutableArray array];
    
    // Create a token view to determine the height of a line
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.scrollView.scrollsToTop = NO;
    self.scrollView.delegate = self;
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self addSubview:self.scrollView];
    
    // Add placeholder label
    self.placeholderLabel = [[UILabel alloc] init];
    self.placeholderLabel.textColor = [UIColor grayColor];
    self.placeholderLabel.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:self.placeholderLabel];
    
    self.promptLabel = [[UILabel alloc] init];
    self.promptLabel.backgroundColor = [UIColor clearColor];
    self.promptLabel.text = nil;
    [self.promptLabel sizeToFit];
    [self.scrollView addSubview:self.promptLabel];
    
    // Create TextField
    self.textField = [[THEditTextField alloc] init];
    self.textField.delegate = self;
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    self.backgroundColor = [UIColor whiteColor];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:tapGesture];
    
    //default settings
    THTokenView *tokenView = [[THTokenView alloc] initWithName:@""];
    self.tokenViewStyle = tokenView.style;
    self.tokenViewSelectedStyle = tokenView.selectedStyle;
    self.font = tokenView.label.font;
}

#pragma mark - Public functions

- (void)setFont:(UIFont *)font {
    _font = font;
	
    // Create a token view to determine the height of a line
    THTokenView *tokenView = [[THTokenView alloc] initWithName:@"Sample"];
    [tokenView setFont:font];
    self.lineHeight = tokenView.frame.size.height + 2 * kVerticalPadding;
    
    self.textField.font = font;
    [self.textField sizeToFit];
    
    self.promptLabel.font = font;
    self.placeholderLabel.font = font;
    [self updateLabelFrames];
	
	[self setNeedsLayout];
}

- (void)setPromptLabelText:(NSString *)text {
    self.promptLabel.text = text;
    [self updateLabelFrames];
	
    [self setNeedsLayout];
}

- (void)setPromptLabelAttributedText:(NSAttributedString *)attributedText {
    self.promptLabel.attributedText = attributedText;
    [self updateLabelFrames];
    [self setNeedsLayout];
}

- (void)setPlaceholderLabelTextColor:(UIColor *)color{
    self.placeholderLabel.textColor = color;
}

- (void)setPromptLabelTextColor:(UIColor *)color{
    self.promptLabel.textColor = color;
}

- (void)setPromptTintColor:(UIColor *)color{
    self.textField.tintColor = color;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor{
    self.scrollView.backgroundColor = backgroundColor;
    [super setBackgroundColor:backgroundColor];
}

- (void)addToken:(id)token withName:(NSString *)name {
	[self addToken:token withName:name withStyle:self.tokenViewStyle andSelectedStyle:self.tokenViewSelectedStyle];
}

- (void)addToken:(id)token withName:(NSString *)name withStyle:(THTokenViewStyle *)bubbleStyle andSelectedStyle:(THTokenViewStyle *)selectedStyle {
    id tokenKey = [NSValue valueWithNonretainedObject:token];
    if ([self.tokenKeys containsObject:tokenKey]){
        NSLog(@"Cannot add the same object twice to TokenEditView");
        return;
    }
    
    if (self.tokenKeys.count == 1 && self.limitToOne){
        THTokenView *tokenView = [self.tokens objectForKey:[self.tokenKeys firstObject]];
        [self removeTokenView:tokenView];
    }
    
    self.textField.text = @"";
	
	if ([bubbleStyle hasNonWhiteBackground]){
		_tokenHorizontalPadding = kHorizontalPaddingWithBackground;
		_showComma = NO;
	} else {
		_tokenHorizontalPadding = kHorizontalPadding;
		_showComma = !self.limitToOne;
	}
	
    THTokenView *tokenView = [[THTokenView alloc] initWithName:name style:bubbleStyle selectedStyle:selectedStyle showComma:_showComma];
    tokenView.maxWidth = self.frame.size.width - self.promptLabel.frame.origin.x - 2 * _tokenHorizontalPadding - 2 * kHorizontalSidePadding;
    tokenView.minWidth = kTextFieldMinWidth + 2 * _tokenHorizontalPadding;
    tokenView.keyboardAppearance = self.keyboardAppearance;
    tokenView.returnKeyType = self.returnKeyType;
    tokenView.delegate = self;
    [tokenView setFont:self.font];
    
    [self.tokens setObject:tokenView forKey:tokenKey];
    [self.tokenKeys addObject:tokenKey];
    
    if (self.selectedTokenView){
        // if there is a selected token, deselect it
        [self.selectedTokenView unSelect];
        self.selectedTokenView = nil;
        [self selectTextField];
    }
    
    // update the position of the tokens
    [self layoutTokenViews];
    
    // update size of the scrollView
    [UIView animateWithDuration:0.2 animations:^{
        [self layoutScrollView];
    } completion:^(BOOL finished) {
        // scroll to bottom
        _shouldSelectTextField = [self isFirstResponder];
        [self scrollToBottomWithAnimation:YES];
        // after scroll animation [self selectTextField] will be called
    }];
}

- (void)selectTextField {
    self.textField.hidden = NO;
    [self.textField becomeFirstResponder];
}

- (void)removeAllTokens {
    for (id token in [self.tokens allKeys]){
      THTokenView *tokenView = [self.tokens objectForKey:token];
      [tokenView removeFromSuperview];
    }
    [self.tokens removeAllObjects];
    [self.tokenKeys removeAllObjects];
  
    // update layout
    [self setNeedsLayout];
  
    self.textField.hidden = NO;
    self.textField.text = @"";
}

- (void)removeToken:(id)token {
    id tokenKey = [NSValue valueWithNonretainedObject:token];
	[self removeTokenByKey:tokenKey];
}

- (void)setPlaceholderLabelText:(NSString *)text {
    self.placeholderLabel.text = text;

    [self setNeedsLayout];
}

- (BOOL)resignFirstResponder {
    if ([self.textField isFirstResponder])
    {
        return [self.textField resignFirstResponder];
    }
    return [super resignFirstResponder];
}

- (BOOL)isFirstResponder {
	if ([self.textField isFirstResponder]){
		return YES;
	} else if (self.selectedTokenView != nil){
		return YES;
	}
	return NO;
}

- (void)setVerticalPadding:(CGFloat)viewPadding {
    _verticalPadding = viewPadding;

    [self setNeedsLayout];
}

- (void)setTokenViewStyle:(THTokenViewStyle *)style selectedStyle:(THTokenViewStyle *)selectedStyle {
    self.tokenViewStyle = style;
    self.textField.textColor = style.textColor;
    self.tokenViewSelectedStyle = selectedStyle;

    for (id tokenKey in self.tokenKeys){
        THTokenView *tokenView = (THTokenView *)[self.tokens objectForKey:tokenKey];

        tokenView.style = style;
        tokenView.selectedStyle = selectedStyle;

        // this stuff reloads view
        if (tokenView.isSelected){
            [tokenView select];
        } else {
            [tokenView unSelect];
        }
    }
}

- (BOOL)becomeFirstResponder {
    return [self.textField becomeFirstResponder];
}

#pragma mark - Private functions

- (void)scrollToBottomWithAnimation:(BOOL)animated {
    if (animated){
        CGSize size = self.scrollView.contentSize;
        CGRect frame = CGRectMake(0, size.height - self.scrollView.frame.size.height, size.width, self.scrollView.frame.size.height);
        
        [self.scrollView scrollRectToVisible:frame animated:animated];
    } else {
        // this block is here because scrollRectToVisible with animated NO causes crashes on iOS 5 when the user tries to delete many tokens really quickly
        CGPoint offset = self.scrollView.contentOffset;
        offset.y = self.scrollView.contentSize.height - self.scrollView.frame.size.height;
        self.scrollView.contentOffset = offset;
    }
}

- (void)removeTokenView:(THTokenView *)tokenView {
    id token = [self tokenForTokenView:tokenView];
    
    if (token == nil){
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(tokenEdit:didRemoveToken:)]){
        [self.delegate tokenEdit:self didRemoveToken:[token nonretainedObjectValue]];
    }
    
    [self removeTokenByKey:token];
    [self selectTextField];

    if (self.selectedTokenView == tokenView) {
        self.selectedTokenView = nil;
    }
}

- (void)removeTokenByKey:(id)tokenKey {
    // Remove tokenView from view
    THTokenView *tokenView = [self.tokens objectForKey:tokenKey];
    [tokenView removeFromSuperview];
  
    // Remove token from memory
    [self.tokens removeObjectForKey:tokenKey];
    [self.tokenKeys removeObject:tokenKey];

	self.textField.text = @"";

	// update layout
	[self layoutTokenViews];
	
	// animate resizing of view
	[UIView animateWithDuration:0.2 animations:^{
		[self layoutScrollView];
	} completion:^(BOOL finished) {
		[self scrollToBottomWithAnimation:NO];
	}];
}

- (id)tokenForTokenView:(THTokenView *)tokenView {
    NSArray *keys = [self.tokens allKeys];
    
    for (id token in keys){
        if ([[self.tokens objectForKey:token] isEqual:tokenView]){
            return token;
        }
    }
    return nil;
}

- (void)updateLabelFrames {
    [self.promptLabel sizeToFit];
    self.promptLabel.frame = CGRectMake(kHorizontalSidePadding, self.verticalPadding, self.promptLabel.frame.size.width, self.lineHeight);
    self.placeholderLabel.frame = CGRectMake([self firstLineXOffset] + 3, self.verticalPadding, self.frame.size.width, self.lineHeight);
}

- (CGFloat)firstLineXOffset {
    if (self.promptLabel.text == nil){
        return kHorizontalSidePadding;
    } else {
        return self.promptLabel.frame.origin.x + self.promptLabel.frame.size.width + 1;
    }
}

- (void)layoutTokenViews {
	_frameOfLastView = CGRectNull;
	_lineCount = 0;
	
	// Loop through tokens and position/add them to the view
	for (id tokenKey in self.tokenKeys){
		THTokenView *tokenView = (THTokenView *)[self.tokens objectForKey:tokenKey];
		CGRect tokenViewFrame = tokenView.frame;
		
		if (CGRectIsNull(_frameOfLastView)){
			// First token view
			tokenViewFrame.origin.x = [self firstLineXOffset];
			tokenViewFrame.origin.y = kVerticalPadding + self.verticalPadding;
		} else {
			// Check if token view will fit on the current line
			CGFloat width = tokenViewFrame.size.width + 2 * _tokenHorizontalPadding;
			if (self.frame.size.width - kHorizontalSidePadding - _frameOfLastView.origin.x - _frameOfLastView.size.width - width >= 0){
				// add to the same line
				// Place token view just after last token view on the same line
				tokenViewFrame.origin.x = _frameOfLastView.origin.x + _frameOfLastView.size.width + _tokenHorizontalPadding * 2;
				tokenViewFrame.origin.y = _frameOfLastView.origin.y;
			} else {
				// No space on current line, jump to next line
				_lineCount++;
				tokenViewFrame.origin.x = kHorizontalSidePadding;
				tokenViewFrame.origin.y = (_lineCount * self.lineHeight) + kVerticalPadding + self.verticalPadding;
			}
		}
		_frameOfLastView = tokenViewFrame;
		tokenView.frame = tokenViewFrame;
		
		// Add token view if it hasn't been added
		if (tokenView.superview == nil){
			[self.scrollView addSubview:tokenView];
		}
	}
	
	// Now add the textField after the token views
	CGFloat minWidth = kTextFieldMinWidth + 2 * _tokenHorizontalPadding;
	CGFloat textFieldHeight = self.lineHeight - 2 * kVerticalPadding;
	CGRect textFieldFrame = CGRectMake(0, 0, self.textField.frame.size.width, textFieldHeight);
	
	// Check if we can add the text field on the same line as the last token view
	if (self.frame.size.width - kHorizontalSidePadding - _frameOfLastView.origin.x - _frameOfLastView.size.width - minWidth >= 0){ // add to the same line
		textFieldFrame.origin.x = _frameOfLastView.origin.x + _frameOfLastView.size.width + _tokenHorizontalPadding;
		textFieldFrame.size.width = self.frame.size.width - textFieldFrame.origin.x;
	} else {
		// place text view on the next line
		_lineCount++;
		
		textFieldFrame.origin.x = kHorizontalSidePadding;
		textFieldFrame.size.width = self.frame.size.width - 2 * _tokenHorizontalPadding;
		
		if (self.tokens.count == 0){
			_lineCount = 0;
			textFieldFrame.origin.x = [self firstLineXOffset];
			textFieldFrame.size.width = self.bounds.size.width - textFieldFrame.origin.x;
		}
	}
	
	textFieldFrame.origin.y = _lineCount * self.lineHeight + kVerticalPadding + self.verticalPadding;
	self.textField.frame = textFieldFrame;
	
	// Add text view if it hasn't been added
	self.textField.center = CGPointMake(self.textField.center.x, _lineCount * self.lineHeight + textFieldHeight / 2 + kVerticalPadding + self.verticalPadding);
	
	if (self.textField.superview == nil){
		[self.scrollView addSubview:self.textField];
	}
	
	// Hide the text view if we are limiting number of selected tokens to 1 and a token has already been added
	if (self.limitToOne && self.tokens.count >= 1){
		self.textField.hidden = YES;
		_lineCount = 0;
	}
	
	// Show placeholder if no there are no tokens
    if ([self.textField.text isEqualToString:@""] && self.tokens.count == 0 ){
		self.placeholderLabel.hidden = NO;
	} else {
		self.placeholderLabel.hidden = YES;
	}
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	[self layoutTokenViews];
	
	[self layoutScrollView];
}

- (void)layoutScrollView {
	// Adjust scroll view content size
	CGRect frame = self.bounds;
	CGFloat maxFrameHeight = self.maxNumberOfLines * self.lineHeight + 2 * self.verticalPadding; // limit frame to two lines of content
	CGFloat newHeight = (_lineCount + 1) * self.lineHeight + 2 * self.verticalPadding;
	self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, newHeight);
	
	// Adjust frame of view if necessary
	newHeight = (newHeight > maxFrameHeight) ? maxFrameHeight : newHeight;
	if (self.frame.size.height != newHeight){
		// Adjust self height
		CGRect selfFrame = self.frame;
		selfFrame.size.height = newHeight;
		self.frame = selfFrame;
		
		// Adjust scroll view height
		frame.size.height = newHeight;
		self.scrollView.frame = frame;
		
		if ([self.delegate respondsToSelector:@selector(tokenEditDidResize:)]){
			[self.delegate tokenEditDidResize:self];
		}
	}
}

#pragma mark - THTokenTextFieldDelegate

- (void)textFieldDidHitBackspaceWithEmptyText:(THEditTextField *)textField {
    self.textField.hidden = NO;
    
    if (self.tokens.count) {
        // Capture "delete" key press when cell is empty
        self.selectedTokenView = [self.tokens objectForKey:[self.tokenKeys lastObject]];
        [self.selectedTokenView select];
    } else {
        if ([self.delegate respondsToSelector:@selector(tokenEdit:textFieldDidChange:)]){
            [self.delegate tokenEdit:self textFieldDidChange:textField];
        }
    }
}

- (void)textFieldDidChange:(THEditTextField *)textField {
    if ([self.delegate respondsToSelector:@selector(tokenEdit:textFieldDidChange:)]
        && !self.textField.markedTextRange) {
        [self.delegate tokenEdit:self textFieldDidChange:textField];
    }

    if ([textField.text isEqualToString:@""] && self.tokens.count == 0){
        self.placeholderLabel.hidden = NO;
    } else {
        self.placeholderLabel.hidden = YES;
    }
    
    CGPoint offset = self.scrollView.contentOffset;
    offset.y = self.scrollView.contentSize.height - self.scrollView.frame.size.height;
    if (offset.y > self.scrollView.contentOffset.y){
        [self scrollToBottomWithAnimation:YES];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if ([self.delegate respondsToSelector:@selector(tokenEdit:textFieldShouldReturn:)]){
		return [self.delegate tokenEdit:self textFieldShouldReturn:textField];
	}
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
   	if ([self.delegate respondsToSelector:@selector(tokenEdit:textFieldDidBeginEditing:)]){
        [self.delegate tokenEdit:self textFieldDidBeginEditing:textField];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
   	if ([self.delegate respondsToSelector:@selector(tokenEdit:textFieldDidEndEditing:)]){
        [self.delegate tokenEdit:self textFieldDidEndEditing:textField];
    }
}

#pragma mark - THTokenViewDelegate Functions

- (void)tokenViewWasSelected:(THTokenView *)tokenView {
    if (self.selectedTokenView != nil){
        [self.selectedTokenView unSelect];
    }
    self.selectedTokenView = tokenView;
    
    id token = [self tokenForTokenView:tokenView];
    if ([self.delegate respondsToSelector:@selector(tokenEdit:didSelectToken:)]){
        [self.delegate tokenEdit:self didSelectToken:[token nonretainedObjectValue]];
    }
    
    [self.textField resignFirstResponder];
    self.textField.text = @"";
    self.textField.hidden = YES;
}

- (void)tokenViewWasUnSelected:(THTokenView *)tokenView {
    if (self.selectedTokenView == tokenView){
        self.selectedTokenView = nil;
    }

    [self selectTextField];
	// transfer the text fromt he textField within the TokenView if there was any
	// ***This is important if the user starts to type when a token view is selected
    self.textField.text = tokenView.textField.text;

	// trigger textFieldDidChange if there is text in the textField
	if (self.textField.text.length > 0){
		[self textFieldDidChange:self.textField];
	}
}

- (void)tokenViewShouldBeRemoved:(THTokenView *)tokenView {
    [self removeTokenView:tokenView];
}

#pragma mark - Gesture Recognizer

- (void)handleTapGesture {
    if (self.limitToOne && self.tokenKeys.count == 1){
        return;
    }
    [self scrollToBottomWithAnimation:YES];
    
    // Show textField
    [self selectTextField];
    
    // Unselect token view
    [self.selectedTokenView unSelect];
    self.selectedTokenView = nil;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (_shouldSelectTextField){
        _shouldSelectTextField = NO;
        [self selectTextField];
    }
}

#pragma mark - UITextInputTraits

- (void)setKeyboardAppearance:(UIKeyboardAppearance)keyboardAppearance {
    self.textField.keyboardAppearance = keyboardAppearance;
    for (THTokenView *tokenView in self.tokens) {
        tokenView.keyboardAppearance = keyboardAppearance;
    }
}

- (UIKeyboardAppearance)keyboardAppearance {
    return self.textField.keyboardAppearance;
}

- (void)setReturnKeyType:(UIReturnKeyType)returnKeyType {
    self.textField.returnKeyType = returnKeyType;
    for (THTokenView *tokenView in self.tokens) {
        tokenView.returnKeyType = returnKeyType;
    }
}

- (UIReturnKeyType)returnKeyType {
    return self.textField.returnKeyType;
}

@end
