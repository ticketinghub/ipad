//
//  MainViewController.m
//  TicketingHub
//
//  Created by Mark on 10/07/2013.
//  Copyright (c) 2013 TicketingHub. All rights reserved.
//

#import "MainViewController.h"

#import "DCTCoreDataStack.h"
#import "DataController.h"
#import "SalesOrDoormanViewController.h"
#import "TXHCommonNames.h"
#import "TXHLoginViewController.h"
#import "TXHUserDefaultsKeys.h"
#import "TXHVenueMO.h"
#import "VenueListController.h"

// Segue Identifiers
static NSString * const VenueListContainerEmbedSegue = @"VenueListContainerEmbed";
static NSString * const SalesOrDoormanContainerEmbedSegue = @"SalesOrDoormanContainerEmbed";

@interface MainViewController ()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) UITapGestureRecognizer  *tapRecogniser;
@property (weak, nonatomic) TXHVenueMO *selectedVenue;
@property (strong, nonatomic) DataController *dataController;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftHandSpace;
@property (weak, nonatomic) IBOutlet UIView *menuContainer;
@property (weak, nonatomic) IBOutlet UIView *tabContainer;


@end

@implementation MainViewController

#pragma mark - Set up and tear down

+ (void)initialize {
    // As this is instantiated early in the app's lifecycle, set up the initial user defaults here
    NSDictionary *defaultsDictionary = @{TXHUserDefaultsLastUserKey : @""};
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsDictionary];
}

- (void)awakeFromNib {
    // Stand up the stack and network controller as early as possible so they are available for the embed segues.
    [self standUpCoreDataStack];
    self.dataController = [[DataController alloc] initWithManagedObjectContext:self.managedObjectContext];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tapRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    self.leftHandSpace.constant = -self.menuContainer.bounds.size.width;

    [self presentLoginViewControllerAnimated:NO completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.leftHandSpace.constant = -self.menuContainer.bounds.size.width;
    [self.view layoutIfNeeded];

    [UIView animateWithDuration:0.4f delay:0.15f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.leftHandSpace.constant = 0.0f;
        [self.view layoutIfNeeded];
    } completion:nil];
}

#pragma mark - Superclass overrides

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueIdentifier = segue.identifier;
    id destinationViewController = segue.destinationViewController;

    if ([segueIdentifier isEqualToString:VenueListContainerEmbedSegue]) {
        VenueListController *venueListController = (VenueListController *)destinationViewController;
        venueListController.managedObjectContext = self.managedObjectContext;
        venueListController.venueSelectionDelegate = self;
    }

}

#pragma mark - Public methods

- (void)presentLoginViewControllerAnimated:(BOOL)animated completion:(void(^)(void))completion {
    TXHLoginViewController *loginViewController = [self.storyboard instantiateViewControllerWithIdentifier:LoginViewControllerStoryboardIdentifier];
    loginViewController.managedObjectContext = self.managedObjectContext;
    loginViewController.dataController = self.dataController;
    
    [self presentViewController:loginViewController animated:animated completion:completion];
}

#pragma mark - Delegate Methods

#pragma mark VenueSelectionProtocol methods

- (void)setSelectedVenue:(TXHVenueMO *)venueMO {
    self.selectedVenue = venueMO;
    [self showOrHideVenueList:nil];
}


#pragma mark - Private methods

- (void)standUpCoreDataStack {
    NSDictionary *options = @{DCTCoreDataStackExcludeFromBackupStoreOption : @YES,
                              NSMigratePersistentStoresAutomaticallyOption : @YES,
                              NSInferMappingModelAutomaticallyOption : @YES};

    NSURL *documentDirectoryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *storeURL = [documentDirectoryURL URLByAppendingPathComponent:@"TicktingHub.sqlite"];

    DCTCoreDataStack *coreDataStack = [[DCTCoreDataStack alloc] initWithStoreURL:storeURL storeType:NSSQLiteStoreType storeOptions:options modelConfiguration:nil modelURL:nil];

    self.managedObjectContext = coreDataStack.managedObjectContext;
}

- (void)tap:(UITapGestureRecognizer *)recogniser {
    [self showOrHideVenueList:nil];
}

#pragma mark Actions

- (IBAction)showOrHideVenueList:(id)sender {
    [UIView animateWithDuration:0.40f animations:^{
        if (self.leftHandSpace.constant == 0.0f) {
            self.leftHandSpace.constant = -self.menuContainer.bounds.size.width;
        } else {
            self.leftHandSpace.constant = 0.0f;
        }
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)logOut:(id)sender {
    [self presentLoginViewControllerAnimated:YES completion:nil];
}

@end
