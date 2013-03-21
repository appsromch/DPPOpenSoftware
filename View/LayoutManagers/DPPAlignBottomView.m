#import "DPPAlignBottomView.h"

@implementation DPPAlignBottomView

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.alignMode = DPPAlignViewBottom;
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.alignMode = DPPAlignViewBottom;
    }
    return self;
}

@end
