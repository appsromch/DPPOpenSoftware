
#import <Foundation/Foundation.h>
@class DPPDataView;

@protocol DPPDataViewDelegate <NSObject>


- (void)view:(DPPDataView *)view didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
@optional
-(void)didFinishInteractionWithView:(DPPDataView *)view;
-(void)didFinishAnimatingWithView:(DPPDataView *)view;
-(void)didStartInteractionWithView:(DPPDataView*)view;
//TODO more tableview stuff if needed

@end
