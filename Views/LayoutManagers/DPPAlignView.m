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
    //collect the original bounds to use as max bounds...
    NSMutableDictionary* viewRects = [NSMutableDictionary dictionary];
    
    for(UIView* subview in self.subviews)
    {
        [viewRects setObject:[NSValue valueWithCGRect:subview.frame] forKey:[NSValue valueWithNonretainedObject:subview]];
    }
    
    self.originalViewRects = viewRects;
    self.hideClippedViews = YES;
 
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
                if([subview isKindOfClass:[UILabel class]])
                {
                    UILabel* labelSubview = (UILabel*)subview;
                    newSize = [labelSubview.text sizeWithFont:labelSubview.font constrainedToSize:labelSubview.frame.size lineBreakMode:labelSubview.lineBreakMode];
                }
                else
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
                if([subview isKindOfClass:[UILabel class]])
                {
                    UILabel* labelSubview = (UILabel*)subview;
                    newSize = [labelSubview.text sizeWithFont:labelSubview.font constrainedToSize:labelSubview.frame.size lineBreakMode:labelSubview.lineBreakMode];
                }
                else
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
                if([subview isKindOfClass:[UILabel class]])
                {
                    UILabel* labelSubview = (UILabel*)subview;
                    newSize = [labelSubview.text sizeWithFont:labelSubview.font constrainedToSize:labelSubview.frame.size lineBreakMode:labelSubview.lineBreakMode];
                }
                else
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
                if([subview isKindOfClass:[UILabel class]])
                {
                    UILabel* labelSubview = (UILabel*)subview;
                    newSize = [labelSubview.text sizeWithFont:labelSubview.font constrainedToSize:labelSubview.frame.size lineBreakMode:labelSubview.lineBreakMode];
                }
                else
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
//-(void)restoreViewOutsideBounds
//{
//    for(int i = 0; i <self.subviews.count;i++)
//    {
//        UIView* subview = [self.subviews objectAtIndex:i];
//        NSNumber* hiddenValue = [self.subviewHiddenState objectAtIndex:i]; 
//        subview.hidden  = [hiddenValue boolValue];
//    }
//}
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
  //  [self restoreViewOutsideBounds];
    switch(alignMode)
    {
        case DPPAlignViewRight:
        {
            [self alignRight];
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
        case DPPAlignViewLeft:
        default:
        {
            [self alignLeft];
        }
        break;
    }
    [self removeViewOutsideBounds];
    [super layoutSubviews];
}

-(CGRect)addRect:(CGRect)rect1 toRect:(CGRect)rect2
{
    return CGRectMake(MIN(rect1.origin.x,rect2.origin.x),MIN(rect1.origin.y,rect2.origin.y),MAX(rect1.origin.x+rect1.size.width,rect2.size.width),MAX(rect1.origin.y+rect1.size.height,rect2.size.height));
}

-(void)dealloc
{
    ARC_RELEASE(originalViewRects release);
    ARC_SUPER_DEALLOC;
}

@end
