//
//  ProductListController.h
//  TicketingHub
//
//  Created by Mark on 10/07/2013.
//  Copyright (c) 2013 TicketingHub. All rights reserved.
//

@import UIKit;

@class TXHTicketingHubClient;

@interface ProductListController : UIViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) TXHTicketingHubClient *ticketingHubClient;

@end