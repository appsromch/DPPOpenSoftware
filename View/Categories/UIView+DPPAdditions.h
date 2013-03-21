//
//  UIView+Additions.h
//
//  Created by Lee Higgins on 12/02/2012.
//  Copyright (c) 2012 DepthPerPixel ltd. All rights reserved.
//

#define UIViewOrEmpty(view) view == nil ? [[UIView alloc] initWithFrame:CGRectZero] : view
@interface UIView(DPPAdditions)

-(UIImage*)captureView;

-(void)insertSubview:(UIView *)view belowSubviews:(NSArray *)siblingSubviews;
-(void)insertSubview:(UIView *)view aboveSubviews:(NSArray *)siblingSubviews;

@end
