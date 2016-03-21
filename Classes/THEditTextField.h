//
//  THTokenTextField.h
//  TokenEdit
//
//  Created by mysteriouss on 14-5-13.
//  Copyright (c) 2014 mysteriouss. All rights reserved.
//

@class THEditTextField;

@protocol THEditTextFieldDelegate<UITextFieldDelegate>

@optional
- (void)textFieldDidChange:(THEditTextField *)textField;
- (void)textFieldDidHitBackspaceWithEmptyText:(THEditTextField *)textField;

@end

@interface THEditTextField : UITextField

@property (nonatomic, assign) id <THEditTextFieldDelegate>delegate;

@end
