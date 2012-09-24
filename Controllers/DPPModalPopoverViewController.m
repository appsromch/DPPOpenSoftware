//
//
//  Created by Lee Higgins on 22/11/2011.
//  Copyright (c) 2011 DepthPerPixel ltd. All rights reserved.
//

#import "DPPModalPopoverViewController.h"
#import "UIView+DPPAdditions.h"


#define animationVeilFadeTime 0.5
#define animationFrameMoveTime 0.3
#define animationFrameMoveDelay 0.2

//Category to allow a modal style presentation..
@implementation UIViewController(DPPModalPopoverViewController)
-(void)presentDPPModalPopoverViewController:(UIViewController*)viewController animated:(BOOL)animated
{
    [DPPModalPopoverViewController presentModalPopoverViewController:viewController fromController:self animated:animated ];
}
@end


@interface DPPModalPopoverViewController()

-(void)veilAnimatedIn;
-(void)frameAnimatedIn;
-(void)veilAnimatedOut;
-(void)frameAnimatedOut;
-(void)animateIn;
-(void)animateOut;
-(void)dismiss;

@end

@implementation DPPModalPopoverViewController

@synthesize backgroundImageView;
@synthesize veilView;
@synthesize containedController;
@synthesize sourceController;

+(void)presentModalPopoverViewController:(UIViewController*)viewController fromController:(UIViewController*)sourceController animated:(BOOL)animated
{
    NSString* nibName = nil;
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        nibName = [NSString stringWithFormat:@"%@_iPad",NSStringFromClass([self class])];
    }
    else
    {
        nibName = [NSString stringWithFormat:@"%@_iPhone",NSStringFromClass([self class])];
        
    }
    DPPModalPopoverViewController* newOverlay = [[DPPModalPopoverViewController alloc] initWithNibName:nibName bundle:nil];//nil will use class name
    newOverlay.sourceController = sourceController;
    newOverlay.containedController = viewController;
    if([newOverlay.containedController respondsToSelector:@selector(setParentVC:)])
    {
        id childVC = newOverlay.containedController;
        [childVC performSelector:@selector(setParentVC:) withObject:newOverlay];
    }
    [sourceController presentModalViewController:newOverlay animated:NO]; //animation contained in newOverlay
    if(animated)
        [newOverlay animateIn];
   // newOverlay.animateAfterLoad = animated;

    //TODO:LH decide if we should use a modal or just add to root window... 
    //screenshot does not work on maps view...
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //grab the source viewControllers view
    
    if(sourceController.navigationController.view!=nil)
    {
        backgroundImageView.image = [sourceController.navigationController.view captureView];
    }
    else
    {
         backgroundImageView.image = [sourceController.view.window captureView];
    }
}

- (void)viewDidUnload
{
    [self setBackgroundImageView:nil];
    [self setVeilView:nil];
    
    [super viewDidUnload];
}
-(void)veilAnimatedIn
{
    if([containedController.view superview] != self.view)
    {
        [containedController viewWillAppear:YES];
        [self.view addSubview:containedController.view];
    }
    
    containedController.view.frame = CGRectOffset(containedController.view.bounds, 0, self.view.bounds.size.height);
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(frameAnimatedIn)];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:animationFrameMoveTime];
    [UIView setAnimationDelay:animationFrameMoveDelay];
    containedController.view.frame =  CGRectOffset(containedController.view.bounds, 0,self.view.bounds.size.height -containedController.view.bounds.size.height);
    [UIView commitAnimations]; 
}
-(void)veilAnimatedOut
{
    [self dismiss];
}
-(void)frameAnimatedIn
{
    [containedController viewDidAppear:YES];
    self.view.userInteractionEnabled = YES;
    
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [containedController viewWillDisappear:animated];
}
-(void)frameAnimatedOut
{
    
}
-(void)animateOut
{
    //TODO:LH use blocks if target OS changes to 4.0+
    
    [containedController viewWillDisappear:YES];
    self.view.userInteractionEnabled = NO;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(veilAnimatedOut)];
    [UIView setAnimationDuration:animationVeilFadeTime];
    [UIView setAnimationDelay:animationFrameMoveDelay];
    veilView.alpha = 0.f;
    [UIView commitAnimations]; 
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(frameAnimatedOut)];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:animationFrameMoveTime];
    containedController.view.frame = CGRectOffset(containedController.view.bounds, 0, self.view.bounds.size.height);
    [UIView commitAnimations];

}

-(void)animateIn
{
    self.view.userInteractionEnabled = NO;
    
    //TODO:LH use blocks if target OS changes to 4.0+
    float targetAlpha = veilView.alpha; //save the current (allows set target alpha in nib)
    veilView.alpha = 0.f;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(veilAnimatedIn)];
    [UIView setAnimationDuration:animationVeilFadeTime];
        veilView.alpha = targetAlpha;
    [UIView commitAnimations]; 
    
}

-(void)dismiss
{
    [sourceController dismissModalViewControllerAnimated:NO];
}

-(IBAction)dismiss:(id)sender
{
    [self animateOut];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return [containedController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}



@end
