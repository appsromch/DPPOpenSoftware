
#import "DPPProgressView.h"
#import "DPPARCCompatibility.h"
@interface DPPProgressView()

-(void)updateView;
-(void)setupViews;

@end

@implementation DPPProgressView

@synthesize trackImage;
@synthesize progressImage;

@synthesize maxProgress;
@synthesize progress;
@synthesize remaining;
@synthesize normalizedProgress;

-(void)awakeFromNib
{
    [super awakeFromNib];
    [self setupViews];
}

-(void)setupViews
{
   // self.progressImage.contentMode = UIViewContentModeLeft;
   // self.progressImage.clipsToBounds =YES;
}

//-(void)setProgress:(float)newProgress animated:(BOOL)animated
//{
//    if(animated)
//    {
//        [UIView beginAnimations:nil context:nil];
//        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//        [UIView setAnimationDuration:0.75];
//        progress = newProgress;
//        [self updateView];
//        [UIView commitAnimations];
//    }
//    else
//    {
//        [self setProgress:newProgress];
//    }
//}
-(void)setProgress:(float)newProgress
{
    progress = newProgress;
    [self updateView];
}

-(UIImageView*)progressImage
{//lazy load
    if(progressImage == nil)
    {
        progressImage = [[UIImageView alloc] initWithFrame:self.bounds];
    }
    return progressImage; 
}

-(UIImageView*)trackImage
{//lazy load
    if(trackImage == nil)
    {
        trackImage = [[UIImageView alloc] initWithFrame:self.bounds];
    }
    return trackImage;
}

-(void)updateView
{
    if(self.trackImage.superview != self)
    {
        [self addSubview:self.trackImage];
    }
    
    if(self.progressImage.superview !=self)
    {
        [self addSubview:self.progressImage];
        [self setupViews];
    }
    
    trackImage.frame = self.bounds;
    
    if(progress == 0)
    {
        progressImage.alpha = 0.0;
    }
    else
    {
        progressImage.hidden = NO;
        progressImage.alpha = 1.0;
        float width = MIN(self.bounds.size.width * self.normalizedProgress,self.bounds.size.width);
        progressImage.frame = CGRectMake(0, 0,width, self.bounds.size.height);
    }
}

-(float)remaining
{
    return maxProgress - progress;
}

-(float)normalizedProgress
{
    return progress / MAX(maxProgress,1.0);
}

-(void)dealloc
{
    ARC_RELEASE(trackImage);
    ARC_RELEASE(progressImage);
    ARC_SUPER_DEALLOC;
}

@end
