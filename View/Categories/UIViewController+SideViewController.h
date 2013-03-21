//
//  UIViewController+SideViewController.h
//  State
//
//  Created by Lee Higgins on 02/08/2012.
//

#import <UIKit/UIKit.h>

#define kSideViewAnimationDuration 0.25
@interface UIViewController (SideViewController)

-(void)presentSideViewController:(UIViewController*)viewController animated:(BOOL)animated;
-(void)dismissSideViewController;
-(BOOL)isPresentingSideViewController;
-(BOOL)isPresentedAsSideViewController;

@end
