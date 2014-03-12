//
//  TXHProductsManager.h
//  TicketingHub
//
//  Created by Bartek Hugo Trzcinski on 19/02/14.
//  Copyright (c) 2014 TicketingHub. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ProductListControllerNotifications.h"

#define TXHPRODUCTSMANAGER [TXHProductsManager sharedManager]

@interface TXHProductsManager : NSObject

@property (strong, nonatomic) TXHProduct *selectedProduct;
@property (strong, nonatomic) TXHAvailability *selectedAvailability;

+ (instancetype)sharedManager;
+ (NSFetchedResultsController *)productsFetchedResultsController;

- (NSString *)priceStringForPrice:(NSNumber *)price;

- (void)fetchSelectedProductAvailabilitiesFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate withCoupon:(NSString *)coupon completion:(void(^)(NSArray *availabilities, NSError *error))completion;

- (void)ticketRecordsForAvailability:(TXHAvailability *)availability andQuery:(NSString *)query completion:(void(^)(NSArray *ricketRecords, NSError *error))completion;

- (void)setTicket:(TXHTicket *)ticket attended:(BOOL)attended completion:(void(^)(TXHTicket *ticket, NSError *error))completion;


@end
