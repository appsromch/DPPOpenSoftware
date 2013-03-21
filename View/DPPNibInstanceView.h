
#import <UIKit/UIKit.h>

@interface DPPNibInstanceView : UIView

//create new instance from nib name, the nib must contain a DPPInstance view in the root, it will choose the first one.
+(id)instanceFromNib:(NSString*)nibName;

//when finished with a view return it to the cache with this function,
//it must have been created using the dequeue method else the view will leak.
+(void)enqueueInstance:(id)object;

//create or reuse a view from cache..
+(id)dequeueInstanceFormNib:(NSString*)nibName;

//replace the current instance with a new instance contained in a nib.
//the frame of the nib view will be set to the callers frame and added to the same point in the view tree (it replaces the caller view).
//this can be used to "contain" nibs inside other nibs...
-(id)replaceWithNibInstance:(NSString*)nibName;
@end
