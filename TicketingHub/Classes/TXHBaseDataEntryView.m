//
//  TXHBaseDataEntryView.m
//  TicketingHub
//
//  Created by Mark on 14/08/2013.
//  Copyright (c) 2013 TicketingHub. All rights reserved.
//

#import "TXHBaseDataEntryView.h"

@import QuartzCore;

#import "TXHDataEntryFieldErrorView.h"

@interface TXHBaseDataEntryView ()

@property (strong, nonatomic) TXHDataEntryFieldErrorView *dataErrorView;
@property (strong, nonatomic) UIView *placeholderView;

// A data content view in which the user will provide appropriate information
@property (strong, nonatomic) UIView *dataContentView;

@end

@implementation TXHBaseDataEntryView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    // Set up default colours
    self.outerColor = [UIColor colorWithRed:238.0f / 255.0f
                                      green:241.0f / 255.0f
                                       blue:243.0f / 255.0f
                                      alpha:1.0f];
    
    self.outerColorForError = [UIColor colorWithRed:255.0f / 255.0f
                                              green:213.0f / 255.0f
                                               blue:216.0f / 255.0f
                                              alpha:1.0f];
    
    self.applyOuterColorToDataEntryField = YES;

    // Create placeHolder for the data entry view
    
    // The placeholder will align with the bottom of the cell allowing room for the error view at the top
    CGRect frame = self.bounds;
    frame.origin.y = 20.0f;
    frame.size.height -= 20.0f;
    _placeholderView = [[UIView alloc] initWithFrame:frame];
    _placeholderView.layer.cornerRadius = 4.0f;
    _placeholderView.backgroundColor = self.outerColor;
    
    _placeholderView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:_placeholderView];
    
    [self setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    
    UIView *tempView = _placeholderView;
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(tempView);
    
    NSArray *constraints = [NSLayoutConstraint
                            constraintsWithVisualFormat:@"H:|[tempView]|"
                            options:0
                            metrics:nil
                            views:viewsDictionary];
    constraints = [constraints arrayByAddingObjectsFromArray:[NSLayoutConstraint
                                                              constraintsWithVisualFormat:@"V:|-20-[tempView]|"
                                                              options:0
                                                              metrics:nil
                                                              views:viewsDictionary]];
    [self addConstraints:constraints];
    
    // Add an error view (Width must be more than 16 for this to work, due to insets on the dataError view).
    _dataErrorView = [[TXHDataEntryFieldErrorView alloc] initWithFrame:CGRectMake(frame.size.width - 50.0f, 10.0f, 40.0f, 20.0f)];
    _dataErrorView.translatesAutoresizingMaskIntoConstraints = NO;
    _dataErrorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _dataErrorView.layer.cornerRadius = 5.0f;
    [self addSubview:_dataErrorView];
    
    TXHDataEntryFieldErrorView *errorView = _dataErrorView;
    viewsDictionary = NSDictionaryOfVariableBindings(errorView);
    
    // Add a width constraint to pin the error view on the left hand side
    constraints = [NSLayoutConstraint
                   constraintsWithVisualFormat:@"H:[errorView]-10-|"
                   options:0
                   metrics:nil
                   views:viewsDictionary];
    
    // Add a height constraint to pin the error view towards the top of the cell & fix it's height to 20
    constraints = [constraints arrayByAddingObjectsFromArray:[NSLayoutConstraint
                                                              constraintsWithVisualFormat:@"V:|-10-[errorView(20)]"
                                                              options:0
                                                              metrics:nil
                                                              views:viewsDictionary]];
    [self addConstraints:constraints];
    
    [self setupDataContent];
}

- (void)setupDataContent {
    // Template method.  Nothing for the base class to do!
}

- (NSString *)errorMessage {
    return self.dataErrorView.message;
}

- (void)setErrorMessage:(NSString *)errorMessage {
    self.dataErrorView.message = errorMessage;
    UIColor *backingColor;
    if (errorMessage.length > 0) {
        backingColor = self.outerColorForError;
    } else {
        backingColor = self.outerColor;
    }
    self.placeholderView.backgroundColor = backingColor;
    if (self.applyOuterColorToDataEntryField) {
        for (UIView *view in self.placeholderView.subviews) {
            view.backgroundColor = backingColor;
        }
    }
}

- (void)setDataContentView:(UIView *)dataContentView {
    if (_dataContentView != nil) {
        [_dataContentView removeFromSuperview];
        _dataContentView = nil;
    }
    _dataContentView = dataContentView;
    
    CGRect frame = CGRectInset(self.placeholderView.bounds, 8.0f, 0.0f);
    dataContentView.frame = frame;
    [self.placeholderView addSubview:dataContentView];
    if (self.applyOuterColorToDataEntryField) {
        _dataContentView.backgroundColor = self.placeholderView.backgroundColor;
    }
}


- (void)updateDataContentView:(UIView *)dataContentView {
    self.dataContentView = dataContentView;
    self.dataContentView.tintColor = self.tintColor;
}

@end
