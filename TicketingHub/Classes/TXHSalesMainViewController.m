//
//  TXHSalesMainViewController.m
//  TicketingHub
//
//  Created by Mark on 08/07/2013.
//  Copyright (c) 2013 TicketingHub. All rights reserved.
//

#import "TXHSalesMainViewController.h"

// child controllers
#import "TXHTransitionSegue.h"
#import "TXHSalesWizardDetailsViewController.h"
#import "TXHSalesWizardViewController.h"

// steps data
#import "TXHSalesStepAbstract.h"
#import "TXHSaleStepsManager.h"

@interface TXHSalesMainViewController () // <TXHSalesWizardDelegate>

@property (weak, nonatomic) IBOutlet UIView *stepsView;
@property (weak, nonatomic) IBOutlet UIView *detailsView;

@property (strong, nonatomic)   TXHSalesWizardViewController *wizardSteps;
@property (strong, nonatomic)   TXHSalesWizardDetailsViewController *wizardDetails;

// data
@property (strong, nonatomic) TXHSaleStepsManager *stepsManager;

@end

@implementation TXHSalesMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.stepsManager = [[TXHSaleStepsManager alloc] initWithSteps:@[@{kWizardStepTitleKey  : NSLocalizedString(@"Tickets", @"Tickets"),
                                                                       kWizardStepDescriptionKey : NSLocalizedString(@"Select Type & Quantity", @"Select Type & Quantity")},

                                                                     @{kWizardStepTitleKey  : NSLocalizedString(@"Information", @"Information"),
                                                                       kWizardStepDescriptionKey : NSLocalizedString(@"Customer details", @"Customer details")},

                                                                     @{kWizardStepTitleKey  : NSLocalizedString(@"Upgrades", @"Upgrades"),
                                                                       kWizardStepDescriptionKey : NSLocalizedString(@"Add ticket extras", @"Add ticket extras")},

                                                                     @{kWizardStepTitleKey  : NSLocalizedString(@"Products", @"Products"),
                                                                       kWizardStepDescriptionKey : NSLocalizedString(@"Optional extras", @"Optional extras")},

                                                                     @{kWizardStepTitleKey  : NSLocalizedString(@"Summary", @"Summary"),
                                                                       kWizardStepDescriptionKey : NSLocalizedString(@"Review the order", @"Review the order")},

                                                                     @{kWizardStepTitleKey  : NSLocalizedString(@"Payment", @"Payment"),
                                                                       kWizardStepDescriptionKey : NSLocalizedString(@"By card, cash or credit", @"By card, cash or credit")},

                                                                     @{kWizardStepTitleKey  : NSLocalizedString(@"Completed", @"Completed"),
                                                                       kWizardStepDescriptionKey : NSLocalizedString(@"Print tickets and recipt", @"Print tickets and recipt")}
                                                                     ]];

    self.wizardSteps.dataSource = self.stepsManager;
    
    [self.wizardSteps reloadWizard];
}

- (IBAction)checkout:(id)sender
{
  [self performSegueWithIdentifier:@"SalesCheckoutSegue" sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
#pragma unused (sender)
    // If this segue is embedding one of the containers give it ourself as a delegate
    if ([segue.identifier isEqualToString:@"Embed Steps"]) {
        self.wizardSteps = segue.destinationViewController;
//        self.wizardSteps.delegate = self;
        return;
    }
    if ([segue.identifier isEqualToString:@"Embed Details"]) {
        self.wizardDetails = segue.destinationViewController;
        self.wizardDetails.delegate = self;
        return;
    }
    
    if ([segue isMemberOfClass:[TXHTransitionSegue class]]) {
        TXHTransitionSegue *transitionSegue = (TXHTransitionSegue *)segue;
        transitionSegue.containerView = self.view;
    }
}

- (void)didChangeOption:(id)sender {
    if ([sender isKindOfClass:[TXHSalesWizardViewController class]] == YES) {
        [self.wizardDetails transition:sender];
    }
    if ([sender isKindOfClass:[TXHSalesWizardDetailsViewController class]] == YES) {
    }
}

- (void)continueFromStep:(NSNumber *)step {
    // We want to progress to the next step
//    [self wizard:self.wizardSteps didChooseOption:step];
}

- (void)completeWizardStep:(id)sender {
}

- (void)orderExpiredWithSender:(id)sender {
}

@end
