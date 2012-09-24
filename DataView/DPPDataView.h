#import <UIKit/UIKit.h>
#import "DPPDataViewDataSource.h"
#import "DPPDataViewDelegate.h"
@interface DPPDataView : UIView

@property (nonatomic,assign) IBOutlet id<DPPDataViewDataSource>  dataSource;
@property (nonatomic,assign) IBOutlet id<DPPDataViewDelegate>    delegate;
@property (nonatomic,retain) NSMutableArray*                    visibleCells;
@property (nonatomic,retain) NSMutableArray*                    visibleIndexPaths;
@property (nonatomic,retain) NSIndexPath*                       selectedIndexPath;

-(void)queueReusableCell:(DPPDataViewCell*)cell withIdentifier:(NSString*)identifier;
-(DPPDataViewCell*)dequeueReusableCellWithIdentifier:(NSString*)identifier;
-(void)selectRowAtIndexPath:(NSIndexPath*)indexPath;
-(void)deSelectRowAtIndexPath:(NSIndexPath*)indexPath;
-(void)reloadData;

@end
