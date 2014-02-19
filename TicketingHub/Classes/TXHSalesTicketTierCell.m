//
//  TXHSalesTicketTierCell.m
//  TicketingHub
//
//  Created by Mark on 31/07/2013.
//  Copyright (c) 2013 TicketingHub. All rights reserved.
//

#import "TXHSalesTicketTierCell.h"

#import <iOS-api/TXHTier+PriceFormatter.h>

@interface TXHSalesTicketTierCell ()

@property (weak, nonatomic) IBOutlet UILabel *tierName;
@property (weak, nonatomic) IBOutlet UITextView *tierDescription;
@property (weak, nonatomic) IBOutlet UILabel *price;
@property (weak, nonatomic) IBOutlet UITextField *quantity;
@property (weak, nonatomic) IBOutlet UIStepper *stepper;

@end

@implementation TXHSalesTicketTierCell

- (void)setTier:(TXHTier *)tier {
    _tier = tier;
    [self configureTierDetails];
    [self layoutIfNeeded];
}

- (void)configureTierDetails {
    self.tierName.text = self.tier.name;
    self.tierDescription.text = self.tier.tierDescription;
    self.quantity.keyboardType = UIKeyboardTypeNumberPad;
    self.price.text = self.tier.priceString;
    self.stepper.maximumValue = self.tier.limit.doubleValue;
}

- (void)quantityDidChange {
    if (self.quantityChangedHandler) {
        self.quantityChangedHandler(@{self.tier.tierId : [NSNumber numberWithInteger:self.quantity.text.integerValue]});
    }
}

#pragma mark - Quantity Value Changed action
- (IBAction)quantityChanged:(id)sender {
#pragma unused (sender)
    // Validate the quantity entered & update the stepper to reflect this new quantity
    NSUInteger quantity = [self.quantity.text integerValue];
    if (quantity < self.stepper.minimumValue) {
        quantity = self.stepper.minimumValue;
    }
    if (quantity > self.stepper.maximumValue) {
        quantity = self.stepper.maximumValue;
    }
    self.stepper.value = quantity;
    self.quantity.text = [NSString stringWithFormat:@"%d", quantity];
    [self quantityDidChange];
}


#pragma mark - Stepper Value Changed action

- (IBAction)stepChanged:(id)sender {
    UIStepper *stepper = sender;
    [self.quantity setText:[NSString stringWithFormat:@"%.0f", stepper.value]];
    [self quantityDidChange];
}

@end
