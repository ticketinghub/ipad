//
//  TXHSalesSummaryViewController.h
//  TicketingHub
//
//  Created by Mark on 13/08/2013.
//  Copyright (c) 2013 TicketingHub. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TXHOrderManager;
@class TXHProductsManager;

@interface TXHSalesSummaryViewController : UIViewController

@property (readonly, nonatomic, getter = isValid) BOOL valid;
@property (readonly, nonatomic) BOOL shouldBeSkiped;

@property (strong, nonatomic) TXHProductsManager *productManager;
@property (strong, nonatomic) TXHOrderManager    *orderManager;

@end
