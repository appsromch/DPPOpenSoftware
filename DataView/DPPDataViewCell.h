#import <UIKit/UIKit.h>

@interface DPPDataViewCell : UIView

@property(nonatomic,retain) NSString* reuseIdentifier;
@property(nonatomic,assign) BOOL selected;

+(id)instanceFromNib:(NSString*)nibName;
-(void)pulseSelected;
@end
