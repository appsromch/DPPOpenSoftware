
#import "DPPDataViewCell.h"
#import "DPPARCCompatibility.h"

@implementation DPPDataViewCell

@synthesize reuseIdentifier;
@synthesize selected;

+(id)instanceFromNib:(NSString*)nibName
{
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
    return [nibViews lastObject];
}

-(NSString*)reuseIdentifier
{
    if(reuseIdentifier ==nil)
    {
        return NSStringFromClass([self class]);
    }
    return reuseIdentifier;
}

-(void)pulseSelected
{
    self.selected = YES;
    [self performSelector:@selector(setSelected:) withObject:[NSNumber numberWithBool:NO] afterDelay:0.1];
}

-(void)dealloc
{
    ARC_RELEASE(reuseIdentifier);
    ARC_SUPER_DEALLOC;
}
@end
