//
//  DPPHorizontalAlignView.h
//  HotelsiPhone
//
//  Created by Lee Higgins on 02/03/2012.
//  Copyright (c) 2012 DepthPerPixel ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {DPPAlignViewLeft,DPPAlignViewRight,DPPAlignViewTop,DPPAlignViewBottom} AlignViewMode;

@interface DPPAlignView : UIView

@property(nonatomic,assign) AlignViewMode alignMode;
@property(nonatomic,assign) float gap;
@property(nonatomic,assign) BOOL hideClippedViews;
@property(nonatomic,readonly) CGRect layoutBounds;

@end
