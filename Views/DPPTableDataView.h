
#import "DPPDataView.h"

@interface DPPTableDataView : DPPDataView <UIScrollViewDelegate>
@property(nonatomic,assign) BOOL                        centerCells;
@property(nonatomic,retain) IBOutlet UIScrollView*      scrollview;                  
@property(nonatomic,retain) IBOutlet UIPageControl*     pageControl;
@property(nonatomic,assign) BOOL                        disableRecogisers;
@property(nonatomic,readonly) NSUInteger                page;

-(void)setPage:(NSUInteger)page animated:(BOOL)animated;
@end
