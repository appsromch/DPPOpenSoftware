#import "DPPAlignTopView.h"

@implementation DPPAlignTopView

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.alignMode = DPPAlignViewTop;
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.alignMode = DPPAlignViewTop;
    }
    return self;
}

@end
