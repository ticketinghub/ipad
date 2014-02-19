//
//  TXHSalesWizardViewControllerDataSource.h
//  TicketingHub
//
//  Created by Bartek Hugo Trzcinski on 18/02/14.
//  Copyright (c) 2014 TicketingHub. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TXHSalesWizardViewController;

@protocol TXHSalesWizardViewControllerDataSource <NSObject>

- (NSUInteger)numberOfsteps;
- (id)stepAtIndex:(NSUInteger)stepIndex;

- (NSUInteger)indexOfStep:(id)step;
- (BOOL)isStepCompleted:(id)step;

- (void)salesWizardViewController:(TXHSalesWizardViewController *)wizard didSelectStepAtIndex:(NSUInteger)stepIndex; // could go to delegate

@optional

- (NSUInteger)currentStepIndex;
- (BOOL)salesWizardViewController:(TXHSalesWizardViewController *)wizard canSelectStepAtIndex:(NSUInteger)stepIndex; // could go to delegate

@end