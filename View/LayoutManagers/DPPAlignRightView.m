#import "DPPAlignRightView.h"

@implementation DPPAlignRightView

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.alignMode = DPPAlignViewRight;
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.alignMode = DPPAlignViewRight;
    }
    return self;
}

@end
