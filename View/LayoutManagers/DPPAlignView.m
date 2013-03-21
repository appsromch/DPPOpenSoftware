//
//  DPPHorizontalAlignView.m
//  HotelsiPhone
//
//  Created by Lee Higgins on 02/03/2012.
//  Copyright (c) 2012 DepthPerPixel ltd. All rights reserved.
//

#import "DPPAlignView.h"
#import "DPPARCCompatibility.h"

@interface DPPAlignView()

@property(nonatomic,retain) NSDictionary* originalViewRects;
@property(nonatomic,retain) NSArray* clippedViews;
@property(nonatomic,retain) NSArray* subviewHiddenState;

@end

@implementation DPPAlignView

@synthesize originalViewRects;
@synthesize gap;
@synthesize alignMode;
@synthesize hideClippedViews;
@synthesize clippedViews;
@synthesize subviewHiddenState;
@synthesize layoutBounds;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.gap=1;
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    [self saveOriginalRects];
    self.hideClippedViews = YES;
 
}

-(void)saveOriginalRects
{
    //collect the original bounds to use as max bounds...
    NSMutableDictionary* viewRects = [NSMutableDictionary dictionary];
    
    for(UIView* subview in self.subviews)
    {
        [viewRects setObject:[NSValue valueWithCGRect:subview.frame] forKey:[NSValue valueWithNonretainedObject:subview]];
    }
    
    self.originalViewRects = viewRects;
    
}

-(void)resetOriginalRects
{
    self.originalViewRects = nil;
}

-(void)alignTop
{
    float accumY = 0;
    layoutBounds = CGRectZero;
    for(UIView* subview in self.subviews)
    {
        NSValue* rectValue = [originalViewRects objectForKey:[NSValue valueWithNonretainedObject:subview]];
        if(rectValue)
        {
            if(!subview.hidden)
            {
                CGRect orignalRect = [rectValue CGRectValue]; 
                subview.bounds = CGRectMake(0,0,orignalRect.size.width,orignalRect.size.height);//reset
                CGSize newSize;
                /*if([subview isKindOfClass:[UILabel class]])
                {
                    UILabel* labelSubview = (UILabel*)subview;
                    newSize = [labelSubview.text sizeWithFont:labelSubview.font constrainedToSize:labelSubview.frame.size lineBreakMode:labelSubview.lineBreakMode];
                }
                else*/
                {
                    newSize = [subview sizeThatFits:orignalRect.size];
                }
                subview.bounds = CGRectMake(0, 0, MIN(newSize.width,orignalRect.size.width), MIN(newSize.height,orignalRect.size.height));
                subview.frame = CGRectOffset(subview.bounds,orignalRect.origin.x,accumY);
                accumY+= subview.bounds.size.height + gap;
                
                layoutBounds = [self addRect:subview.frame toRect:layoutBounds];
            }
        }
    }   
}

-(void)alignMiddle
{
    [self alignTop];
    float middleOffset = (self.bounds.size.height - layoutBounds.size.height) / 2.0;
    for(UIView* subview in self.subviews)
    {
        subview.frame = CGRectOffset(subview.frame, 0, middleOffset);
    }
}

-(void)alignBottom
{
    float accumY =self.bounds.size.height;
    layoutBounds = CGRectZero;
    for(UIView* subview in self.subviews.reverseObjectEnumerator)
    {
        NSValue* rectValue = [originalViewRects objectForKey:[NSValue valueWithNonretainedObject:subview]];
        if(rectValue)
        {
            if(!subview.hidden)
            {
                CGRect orignalRect = [rectValue CGRectValue]; 
                subview.frame = orignalRect;//reset
                CGSize newSize;
                /*if([subview isKindOfClass:[UILabel class]])
                {
                    UILabel* labelSubview = (UILabel*)subview;
                    [labelSubview sizeToFit];
                    newSize = labelSubview.bounds.size;
                   // newSize = [labelSubview.text sizeWithFont:labelSubview.font constrainedToSize:labelSubview.frame.size lineBreakMode:labelSubview.lineBreakMode];
                }
                else*/
                {
                    newSize = [subview sizeThatFits:orignalRect.size];
                }
                subview.bounds = CGRectMake(0, 0, MIN(newSize.width,orignalRect.size.width), MIN(newSize.height,orignalRect.size.height));
                subview.frame = CGRectOffset(subview.bounds, orignalRect.origin.x,accumY-subview.bounds.size.height);
                accumY-= subview.bounds.size.height + gap;
                layoutBounds = [self addRect:subview.frame toRect:layoutBounds];
            }
        }
    }   
}

-(void)alignLeft
{
    float accumX = 0;
    layoutBounds = CGRectZero;
    for(UIView* subview in self.subviews)
    {
        NSValue* rectValue = [originalViewRects objectForKey:[NSValue valueWithNonretainedObject:subview]];
        if(rectValue)
        {
            if(!subview.hidden)
            {
                CGRect orignalRect = [rectValue CGRectValue]; 
                subview.frame = orignalRect;//reset
                CGSize newSize;
               /* if([subview isKindOfClass:[UILabel class]])
                {
                    UILabel* labelSubview = (UILabel*)subview;
                    newSize = [labelSubview.text sizeWithFont:labelSubview.font constrainedToSize:labelSubview.frame.size lineBreakMode:labelSubview.lineBreakMode];
                }
                else*/
                {
                    newSize = [subview sizeThatFits:orignalRect.size];
                }
                subview.bounds = CGRectMake(0, 0, MIN(newSize.width,orignalRect.size.width), MIN(newSize.height,orignalRect.size.height));
                subview.frame = CGRectOffset(subview.bounds, accumX,orignalRect.origin.y);
                accumX+= subview.bounds.size.width + gap;
                layoutBounds = [self addRect:subview.frame toRect:layoutBounds];
            }
        }
    }  
}

-(void)alignCentre
{
    [self alignLeft];
    float centreOffset = (self.bounds.size.width - layoutBounds.size.width) / 2.0;
    for(UIView* subview in self.subviews)
    {
        subview.frame = CGRectOffset(subview.frame, centreOffset, 0);
    }
}

-(void)alignRight
{
    float accumX =self.bounds.size.width;
    layoutBounds = CGRectZero;
    for(UIView* subview in self.subviews.reverseObjectEnumerator)
    {
        NSValue* rectValue = [originalViewRects objectForKey:[NSValue valueWithNonretainedObject:subview]];
        if(rectValue)
        {
            if(!subview.hidden)
            {
                CGRect orignalRect = [rectValue CGRectValue]; 
                subview.frame = orignalRect;//reset
                CGSize newSize;
                /*if([subview isKindOfClass:[UILabel class]])
                {
                    UILabel* labelSubview = (UILabel*)subview;
                    newSize = [labelSubview.text sizeWithFont:labelSubview.font constrainedToSize:labelSubview.frame.size lineBreakMode:labelSubview.lineBreakMode];
                }
                else*/
                {
                    newSize = [subview sizeThatFits:orignalRect.size];
                }
                subview.bounds = CGRectMake(0, 0, MIN(newSize.width,orignalRect.size.width), MIN(newSize.height,orignalRect.size.height));
                subview.frame = CGRectOffset(subview.bounds, accumX-subview.bounds.size.width,orignalRect.origin.y);
                accumX -= subview.bounds.size.width + gap;
                layoutBounds = [self addRect:subview.frame toRect:layoutBounds];
            }
        }
    }   
}

-(void)flowFromLeft
{
    float accumX =0;
    float accumY =0;
    float lineHeight = 0;
    int lineCount = 0;
    layoutBounds = CGRectZero;
    for(UIView* subview in self.subviews)
    {
        NSValue* rectValue = [originalViewRects objectForKey:[NSValue valueWithNonretainedObject:subview]];
        if(rectValue)
        {
            if(!subview.hidden)
            {
                CGRect orignalRect = [rectValue CGRectValue];
                subview.frame = orignalRect;//reset
                CGSize newSize;
                /*if([subview isKindOfClass:[UILabel class]])
                 {
                 UILabel* labelSubview = (UILabel*)subview;
                 newSize = [labelSubview.text sizeWithFont:labelSubview.font constrainedToSize:labelSubview.frame.size lineBreakMode:labelSubview.lineBreakMode];
                 }
                 else*/
                {
                    newSize = [subview sizeThatFits:orignalRect.size];
                }
                subview.bounds = CGRectMake(0, 0, MIN(newSize.width,orignalRect.size.width), MIN(newSize.height,orignalRect.size.height));
                subview.frame = CGRectOffset(subview.bounds, accumX,accumY);
                accumX += subview.bounds.size.width + gap;
                if(accumX > self.bounds.size.width && lineCount > 0)
                {
                    accumX = 0;
                    accumY+= lineHeight + gap;
                    subview.frame = CGRectMake(accumX,accumY,subview.frame.size.width,subview.frame.size.height);
                    lineHeight = subview.frame.size.height;
                    lineCount =0;
                    accumX += subview.bounds.size.width + gap;
                }
                else
                {
                    lineHeight = MAX(lineHeight,subview.frame.size.height);
                    lineCount++;
                }
                layoutBounds = [self addRect:subview.frame toRect:layoutBounds];
            }
        }
    }
}


-(void)removeViewOutsideBounds
{
    if(hideClippedViews)
    {
        self.clipsToBounds = YES;
        NSMutableArray* originalHiddenState = [NSMutableArray array];
        for(UIView* subview in self.subviews)
        {
            [originalHiddenState addObject:[NSNumber numberWithBool:subview.hidden]];
            CGRect subFrame = subview.frame;
            CGRect intersection = CGRectIntersection(subFrame, self.bounds);
            if(CGRectIsNull(intersection))
            {
                 subview.frame = CGRectOffset(subview.bounds, -subview.bounds.size.width,-subview.bounds.size.height);  
            }
            else
            {
                if(!(intersection.size.width == subFrame.size.width && 
                   intersection.size.height == subFrame.size.height))
                {
                     subview.frame = CGRectOffset(subview.bounds, -subview.bounds.size.width,-subview.bounds.size.height);  
                }
            }
        }
        self.subviewHiddenState = originalHiddenState;
    }
}

-(void)layoutSubviews
{
    switch(alignMode)
    {
        case DPPAlignViewRight:
        {
            [self alignRight];
        }
        break;
        case DPPAlignViewMiddle:
        {
            [self alignMiddle];
        }
        break;
        case DPPAlignViewCentre:
        {
            [self alignCentre];
        }
        break;
        case DPPAlignViewTop:
        {
            [self alignTop];
        }
        break;
        case DPPAlignViewBottom:
        {
            [self alignBottom];
        }
        break;
        case DPPAlignViewFlowFromLeft:
        {
            [self flowFromLeft];
        }
        break;
        case DPPAlignViewLeft:
        default:
        {
            [self alignLeft];
        }
        break;
    }
//    [self removeViewOutsideBounds];
    [super layoutSubviews];
    if ([self.delegate respondsToSelector:@selector(alignViewDidLayoutSubviews:)]) {
        [self.delegate alignViewDidLayoutSubviews:self];
    }
}

-(CGRect)addRect:(CGRect)rect1 toRect:(CGRect)rect2
{
    return CGRectUnion(rect1, rect2);
    //return CGRectMake(MIN(rect1.origin.x,rect2.origin.x),MIN(rect1.origin.y,rect2.origin.y),MAX(rect1.origin.x+rect1.size.width,rect2.size.width),MAX(rect1.origin.y+rect1.size.height,rect2.size.height));
}

-(void)sizeToFit
{
    [self layoutSubviews];
    self.bounds = self.layoutBounds;
}

-(void)dealloc
{
    ARC_RELEASE(originalViewRects release);
    ARC_SUPER_DEALLOC;
}

@end
