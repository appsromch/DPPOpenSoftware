//
//
//  Created by Lee Higgins on 22/11/2011.
//  Copyright (c) 2011 DepthPerPixel ltd. All rights reserved.
//


//The idea of this component is to give a modal overlay, but in the style of the uiActionsheet
//we use a modal view controller and set its background to be a screenshot of the original background
//this allows the views below to be unloaded in low memory warnings


#import <UIKit/UIKit.h>

@interface UIViewController(DPPModalPopoverViewController)

-(void)presentDPPModalPopoverViewController:(UIViewController*)viewController animated:(BOOL)animated;
-(void)pushDPPModalPopoverViewController:(UIViewController*)viewController animated:(BOOL)animated;
@end

@interface DPPModalPopoverViewController : UIViewController


@property(nonatomic,assign) UIViewController* sourceController;
@property(nonatomic,retain) UIViewController* containedController;
@property(nonatomic,retain) IBOutlet UIImageView* backgroundImageView;
@property(nonatomic,retain) IBOutlet UIView* veilView; //set the background colour to change style of fade

+(void)presentModalPopoverViewController:(UIViewController*)viewController fromController:(UIViewController*)sourceController animated:(BOOL)animated;
+(void)pushModalPopoverViewController:(UIViewController*)viewController inNavigation:(UINavigationController*)sourceController animated:(BOOL)animated;
-(IBAction)dismiss:(id)sender;

@end
