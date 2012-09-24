#import "DPPAlignLeftView.h"

@implementation DPPAlignLeftView

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.alignMode = DPPAlignViewLeft;
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.alignMode = DPPAlignViewLeft;
    }
    return self;
}

@end
