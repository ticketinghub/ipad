//
//  TXHSalesWizardDetailsViewController.m
//  TicketingHub
//
//  Created by Mark on 29/07/2013.
//  Copyright (c) 2013 TicketingHub. All rights reserved.
//

#import "TXHSalesWizardDetailsViewController.h"

#import "TXHEmbeddingSegue.h"
#import "TXHSalesInformationViewController.h"
#import "TXHSalesTicketViewController.h"
#import "TXHSalesTimerViewController.h"
#import "TXHTransitionSegue.h"

@interface TXHSalesWizardDetailsViewController ()

@property (weak, nonatomic) IBOutlet UIView *detailView;

@property (strong, nonatomic) TXHSalesTimerViewController *timeController;

@end

@implementation TXHSalesWizardDetailsViewController

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
	// Do any additional setup after loading the view.
    [self performSegueWithIdentifier:@"Embed InformationPane" sender:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
#pragma unused (sender)
    if ([segue.identifier isEqualToString:@"TXHSalesTimerViewController"]) {
        self.timeController = segue.destinationViewController;
    }
    
    if ([segue.identifier isEqualToString:@"Embed InformationPane"])
    {
        TXHEmbeddingSegue *embeddingSegue = (TXHEmbeddingSegue *)segue;
        
        embeddingSegue.containerView = self.detailView;
        
        return;
    }
    
    if ([segue isMemberOfClass:[TXHTransitionSegue class]]) {
        TXHTransitionSegue *transitionSegue = (TXHTransitionSegue *)segue;
        
        transitionSegue.containerView = self.detailView;
        
        if ([segue.identifier isEqualToString:@"Transition To Step1"]) {
            TXHSalesTicketViewController *salesTicketController = transitionSegue.destinationViewController;
            salesTicketController.delegate = self.delegate;
        }
//        else
//        {
//            transitionSegue.animationOptions = UIViewAnimationOptionTransitionCurlUp;
//        }
    }
}

@end
