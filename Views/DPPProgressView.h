
#import <UIKit/UIKit.h>

@interface DPPProgressView : UIView

@property(nonatomic,retain) IBOutlet UIImageView* progressImage;
@property(nonatomic,retain) IBOutlet UIImageView* trackImage;

@property(nonatomic,assign)     float progress;
@property(nonatomic,assign)     float remaining;
@property(nonatomic,assign)     float maxProgress;
@property(nonatomic,readonly)   float normalizedProgress;


//-(void)setProgress:(float)newProgress animated:(BOOL)animated;

@end
