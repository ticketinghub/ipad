//
//  TXHSalesTicketViewController.h
//  TicketingHub
//
//  Created by Mark on 31/07/2013.
//  Copyright (c) 2013 TicketingHub. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TXHSalesTicketViewController : UIViewController

@property (strong, nonatomic) id delegate;

- (void)continueFromStep:(NSNumber *)step;

@end
