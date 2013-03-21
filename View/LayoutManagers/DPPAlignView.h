//
//  DPPHorizontalAlignView.h
//  HotelsiPhone
//
//  Created by Lee Higgins on 02/03/2012.
//  Copyright (c) 2012 DepthPerPixel ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    DPPAlignViewLeft,
    DPPAlignViewCentre,
    DPPAlignViewRight,
    DPPAlignViewTop,
    DPPAlignViewMiddle,
    DPPAlignViewBottom,
    DPPAlignViewFlowFromLeft
} AlignViewMode;


@class DPPAlignView;

@protocol DPPAlignViewDelegate <NSObject>

- (void)alignViewDidLayoutSubviews:(DPPAlignView *)alignView;

@end


@interface DPPAlignView : UIView

@property(nonatomic,assign) AlignViewMode alignMode;
@property(nonatomic,assign) float gap;
@property(nonatomic,assign) BOOL hideClippedViews;
@property(nonatomic,readonly) CGRect layoutBounds;
@property(nonatomic, weak) IBOutlet id<DPPAlignViewDelegate> delegate;

-(void)saveOriginalRects;
-(void)resetOriginalRects;

@end
