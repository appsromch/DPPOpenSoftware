//
//  UIViewController+SideViewController.m
//
//  Created by Lee Higgins on 02/08/2012.
//  Copyright (c) 2012 DepthPerPixel ltd. All rights reserved.
//

#import "UIViewController+SideViewController.h"
#import <objc/runtime.h>

static NSString* kSideViewController_masterSideViewController = @"SideViewController_masterSideViewController";
static NSString* kSideViewController_sideViewController = @"SideViewController_sideViewController";
//static NSString* kSideViewController_sideViewControllerAnimating = @"SideViewController_sideViewControllerAnimating";

@implementation UIViewController (SideViewController)

-(void)presentSideViewController:(UIViewController*)viewController animated:(BOOL)animated
{
    [viewController setMasterSideViewController:self];
    [self setSideViewController:viewController];
        
    //ensure we are just behind the top view.
    [viewController.view removeFromSuperview];
    if(self.navigationController !=nil)
    {
        viewController.view.frame = self.navigationController.view.frame;
        [self.navigationController.view.superview insertSubview:viewController.view belowSubview:self.navigationController.view];
    }
    else
    {
        viewController.view.frame = self.view.superview.frame;
        [self.view.superview insertSubview:viewController.view belowSubview:self.view];
    }
    
    [viewController viewWillAppear:YES];
    if(animated)
    {
        [UIView animateWithDuration:kSideViewAnimationDuration delay:0 options:UIViewAnimationCurveEaseIn animations:^{
            if(self.navigationController !=nil)
            {
                self.navigationController.view.center = CGPointMake(self.navigationController.view.bounds.size.width*1.25,self.navigationController.view.center.y);
            }
            else
            {
                self.view.center = CGPointMake(self.view.bounds.size.width*1.25,self.view.center.y);
            }
        } completion:^(BOOL finished)
         {
             if(finished)
             {
                 [viewController viewDidAppear:YES];
             }
         }];
    }
    else
    {
        [viewController viewDidAppear:YES];
    }
    
}

-(BOOL)isPresentingSideViewController
{
    return ([self sideViewController]!=nil);
}

-(BOOL)isPresentedAsSideViewController
{
    return ([self masterSideViewController])!=nil;
}

-(void)dismissSideViewController
{
    UIViewController* master = [self masterSideViewController];
    UIViewController* sideviewController = [self sideViewController];
    if(master!=nil)
    { //has a master set so tell it to dismiss us....
        [master dismissSideViewController];
    }
    else if(sideviewController!=nil)
    {
        [sideviewController viewWillDisappear:YES];
        [UIView animateWithDuration:kSideViewAnimationDuration delay:0 options:UIViewAnimationCurveEaseOut animations:^{
            if(self.navigationController!=nil)
            {
                self.navigationController.view.center = CGPointMake(self.view.bounds.size.width/2,
                                                                self.navigationController.view.center.y);
            }
            else
            {
                self.view.center = CGPointMake(self.view.bounds.size.width/2,
                                              self.view.center.y);
            }
        } completion:^(BOOL finished){
        
            if(finished)
            {
                [sideviewController viewDidDisappear:YES];
                [sideviewController.view removeFromSuperview];
                [sideviewController setMasterSideViewController:nil];
                [self setSideViewController:nil];
            }
        }];
    }
}

-(void)setMasterSideViewController:(UIViewController*)viewController
{
    objc_setAssociatedObject(self, &kSideViewController_masterSideViewController,viewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UIViewController*)masterSideViewController
{
    return objc_getAssociatedObject(self, &kSideViewController_masterSideViewController);
}

-(void)setSideViewController:(UIViewController*)viewController
{
    objc_setAssociatedObject(self, &kSideViewController_sideViewController,viewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UIViewController*)sideViewController
{
    return objc_getAssociatedObject(self, &kSideViewController_sideViewController);
}


@end
