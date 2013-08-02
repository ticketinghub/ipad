//
//  TXHSalesWizardViewController.m
//  TicketingHub
//
//  Created by Mark on 25/07/2013.
//  Copyright (c) 2013 TicketingHub. All rights reserved.
//

#import "TXHSalesWizardViewController.h"

@interface TXHSalesWizardViewController ()

@property (weak, nonatomic) IBOutlet UILabel *dateAndTime;

// Static cell components for step 1 - Tickets
@property (weak, nonatomic) IBOutlet UITableViewCell    *ticketsCell;
@property (weak, nonatomic) IBOutlet UIImageView        *ticketsCellbutton;
@property (weak, nonatomic) IBOutlet UILabel            *ticketsCellTitle;
@property (weak, nonatomic) IBOutlet UILabel            *ticketsCellDescription;

// Static cell components for step 2 - Information
@property (weak, nonatomic) IBOutlet UITableViewCell    *informationCell;
@property (weak, nonatomic) IBOutlet UIImageView        *informationCellbutton;
@property (weak, nonatomic) IBOutlet UILabel            *informationCellTitle;
@property (weak, nonatomic) IBOutlet UILabel            *informationCellDescription;

// Static cell components for step 3 - Upgrades
@property (weak, nonatomic) IBOutlet UITableViewCell    *upgradesCell;
@property (weak, nonatomic) IBOutlet UIImageView        *upgradesCellbutton;
@property (weak, nonatomic) IBOutlet UILabel            *upgradesCellTitle;
@property (weak, nonatomic) IBOutlet UILabel            *upgradesCellDescription;

// Static cell components for step 4 - Products
@property (weak, nonatomic) IBOutlet UITableViewCell    *productsCell;
@property (weak, nonatomic) IBOutlet UIImageView        *productsCellbutton;
@property (weak, nonatomic) IBOutlet UILabel            *productsCellTitle;
@property (weak, nonatomic) IBOutlet UILabel            *productsCellDescription;

// Static cell components for step 5 - Summary
@property (weak, nonatomic) IBOutlet UITableViewCell    *summaryCell;
@property (weak, nonatomic) IBOutlet UIImageView        *summaryCellbutton;
@property (weak, nonatomic) IBOutlet UILabel            *summaryCellTitle;
@property (weak, nonatomic) IBOutlet UILabel            *summaryCellDescription;

// Static cell components for step 6 - Payment
@property (weak, nonatomic) IBOutlet UITableViewCell    *paymentCell;
@property (weak, nonatomic) IBOutlet UIImageView        *paymentCellbutton;
@property (weak, nonatomic) IBOutlet UILabel            *paymentCellTitle;
@property (weak, nonatomic) IBOutlet UILabel            *paymentCellDescription;

// Static cell components for step 7 - Completed
@property (weak, nonatomic) IBOutlet UITableViewCell    *completedCell;
@property (weak, nonatomic) IBOutlet UIImageView        *completedCellbutton;
@property (weak, nonatomic) IBOutlet UILabel            *completedCellTitle;

// An empty circle image indicating a stage not started
@property (strong, nonatomic) UIImage *notStarted;

// A completed image (checkmark on green background) indicating a stage is completed
@property (strong, nonatomic) UIImage *completed;

// An indication of the current stage in progress
@property (assign, nonatomic) NSInteger currentStageInProgress;
@end

@implementation TXHSalesWizardViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    // Set the date & time message for the chosen language - needs to work with an app language in kiosk mode, not the device language
    self.dateAndTime.text = NSLocalizedString(@"Please select date and time from the menu above.", @"Select Date and Time");
    
    // grab the button images
    self.notStarted = [UIImage imageNamed:@"EmptyCircle"];
    self.completed = [UIImage imageNamed:@"Completed"];
    
    // Set up the initial condition
    [self configureWizardForStage:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

#pragma mark - Table view delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
#pragma unused (tableView)
    // The first cell, which contains date / time, cannot be selected
    if (indexPath.row == 0) {
        return nil;
    }
    
    // If the previous stage has been completed we can select this cell
    if (self.currentStageInProgress < indexPath.row - 2) {
        return nil;
    }
    
    // Allow the cell to be selected
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
#pragma unused (tableView)
    [self configureWizardForStage:indexPath.row];
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
#pragma unused (segue, sender)
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark - Wizard business logic

- (void)configureWizardForStage:(NSInteger)stage {
    // Walk the wizard stages backwards - we intend to fall through here
    switch (stage) {
        case 7:
            self.completedCellbutton.image = self.completed;
        case 6:
            if (stage == 6) {
                self.paymentCellbutton.image = self.notStarted;
            } else {
                self.paymentCellbutton.image = self.completed;
            }
        case 5:
            if (stage == 5) {
                self.summaryCellbutton.image = self.notStarted;
            } else {
                self.summaryCellbutton.image = self.completed;
            }
        case 4:
            if (stage == 4) {
                self.productsCellbutton.image = self.notStarted;
            } else {
                self.productsCellbutton.image = self.completed;
            }
        case 3:
            if (stage == 3) {
                self.upgradesCellbutton.image = self.notStarted;
            } else {
                self.upgradesCellbutton.image = self.completed;
            }
        case 2:
            if (stage == 2) {
                self.informationCellbutton.image = self.notStarted;
            } else {
                self.informationCellbutton.image = self.completed;
            }
        case 1:
            if (stage == 1) {
                self.ticketsCellbutton.image = self.notStarted;
            } else {
                self.ticketsCellbutton.image = self.completed;
            }
        default:
            break;
    }
    if (self.currentStageInProgress < stage) {
        self.currentStageInProgress = stage;
    }
    
    // Inform delegate of selection
    [self.delegate wizard:self didChooseOption:@(stage)];
}

- (void)moveToNextStep {
    [self configureWizardForStage:self.currentStageInProgress + 1];
}

- (void)orderExpired {
    self.currentStageInProgress = 0;
    [self configureWizardForStage:self.currentStageInProgress + 1];
}

@end
