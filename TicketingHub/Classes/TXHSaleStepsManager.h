//
//  TXHSaleStepsManager.h
//  TicketingHub
//
//  Created by Bartek Hugo Trzcinski on 18/02/14.
//  Copyright (c) 2014 TicketingHub. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TXHSalesWizardViewControllerDataSource.h"

@class TXHSaleStepsManager;

// notifications are way to messy
@protocol TXHSaleStepsManagerDelegate <NSObject>

- (void)saleStepsManager:(TXHSaleStepsManager *)manager didChangeToStep:(id)step;

@end

@interface TXHSaleStepsManager : NSObject <TXHSalesWizardViewControllerDataSource>

@property (readonly, nonatomic) NSArray *steps;
@property (readonly, nonatomic) NSUInteger currentStepIndex;

@property (weak, nonatomic) id<TXHSaleStepsManagerDelegate> delegate;

- (instancetype)initWithSteps:(NSArray *)steps;
- (void)continueToNextStep;
- (void)resetProcess;
- (BOOL)hasNextStep;

@end