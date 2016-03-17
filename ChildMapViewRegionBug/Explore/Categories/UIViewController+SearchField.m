//
//  UIViewController+SearchField.m
//
//  Created by Scott Atkinson on 3/15/16.
//

#import "UIViewController+SearchField.h"

@implementation UIViewController (SearchField)

- (UITextField *) createSearchFieldWithPlaceholderText:(NSString *) placeholder {
    UITextField * searchField = [[UITextField alloc] init];

    // Look and Feel
    searchField.borderStyle = UITextBorderStyleNone;
    searchField.layer.cornerRadius = 4.0f;
    searchField.layer.masksToBounds = YES;
    searchField.backgroundColor = [UIColor whiteColor];
    [searchField setFont:[UIFont systemFontOfSize:12.0]];

    searchField.placeholder = placeholder;

    searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
//    searchField.clearsOnBeginEditing = YES;
    
    // Keyboard
    searchField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    searchField.autocorrectionType = UITextAutocorrectionTypeNo;
    searchField.spellCheckingType = UITextSpellCheckingTypeNo;
    searchField.enablesReturnKeyAutomatically = YES;
    searchField.keyboardType = UIKeyboardTypeASCIICapable;
    searchField.returnKeyType = UIReturnKeySearch;
    
    UIImageView * searchIcon = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"button-icon-map"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    CGRect frame = searchIcon.frame;
    frame.size.height = 20.0;
    frame.size.width = 20.0;
    searchIcon.frame = frame;
    searchIcon.tintColor = [UIColor lightGrayColor];
    searchIcon.contentMode = UIViewContentModeScaleAspectFit;
    searchIcon.clipsToBounds = YES;
    
    searchField.leftView = searchIcon;
    searchField.leftViewMode = UITextFieldViewModeAlways;

    return searchField;
}

@end
