

#import "DPPTableDataView.h"
#import "DPPARCCompatibility.h"

@interface DPPTableDataView()

-(void)setupView;
-(void)setupGestureRecognizers;
-(void)viewTapped:(UITapGestureRecognizer*)tapGesture;

@property(nonatomic,retain) UITapGestureRecognizer* tapRecog;
@property(nonatomic,assign) BOOL verticalLayout;
@end

@implementation DPPTableDataView

@synthesize scrollview;
@synthesize centerCells;
@synthesize pageControl;
@synthesize disableRecogisers;
@synthesize tapRecog;
@synthesize delegate;
@synthesize verticalLayout;
@synthesize page;

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self setupView];
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    [self setupView];
}

-(void)setupGestureRecognizers
{
    if(!disableRecogisers && [[[UIDevice currentDevice] systemVersion] floatValue] > 3.2)
    {
        UITapGestureRecognizer* newRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
      //  newRec.delaysTouchesEnded = YES;
       // newRec.delaysTouchesBegan = YES;
        //newRec.cancelsTouchesInView =YES;
        [self addGestureRecognizer:newRec];
        self.tapRecog = newRec;
        ARC_RELEASE(newRec release);
    }
}

-(void)setDisableRecogisers:(BOOL)newDisableRecogisers
{
    disableRecogisers = newDisableRecogisers;
    if(tapRecog)
    {
        [self removeGestureRecognizer:tapRecog];
    }
    
}

-(void)setPage:(NSUInteger)newPage animated:(BOOL)animated
{
    CGRect frame;
    frame.origin.x = scrollview.frame.size.width * newPage;
    frame.origin.y = 0;
    frame.size = scrollview.frame.size;
    [self.scrollview scrollRectToVisible:frame animated:animated];
}

-(void)setupView
{
    if(scrollview==nil)
    {
        scrollview = [[UIScrollView alloc] initWithFrame:self.bounds];
        scrollview.clipsToBounds = self.clipsToBounds;
        scrollview.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        scrollview.delegate = self;
    }
    if(scrollview.superview ==nil)
    {
        [self addSubview:scrollview];
    }
    [self setupGestureRecognizers];
}

-(void)viewTapped:(UITapGestureRecognizer*)tapGesture
{
    if(tapGesture.state == UIGestureRecognizerStateRecognized)
    {
        for(int i =0; i< self.visibleCells.count ; i++)
        {
            UIView* view = [self.visibleCells objectAtIndex:i];
            if(CGRectContainsPoint(view.bounds,[tapGesture locationInView:view]))
            {
                if([view isKindOfClass:[DPPDataViewCell class]])
                {
                    DPPDataViewCell* cellView = (DPPDataViewCell*)view;
                    [cellView pulseSelected];
                }
                NSIndexPath* indexPath = [self.visibleIndexPaths objectAtIndex:i];
                if([delegate respondsToSelector:@selector(view:didSelectRowAtIndexPath:)])
                {
                    [self.delegate view:self didSelectRowAtIndexPath:indexPath];
                }
                break;
            }
        }
    }
}

-(void)centerScrollview
{
    if(self.scrollview.contentSize.width < self.scrollview.bounds.size.width)
    {
        self.scrollview.scrollEnabled = NO;
        self.scrollview.contentOffset = CGPointMake((self.scrollview.contentSize.width*0.5)-(self.scrollview.bounds.size.width*0.5), 0);
    }
    else
    {
        self.scrollview.scrollEnabled = YES; 
    }
}

-(void)reloadData
{
    [super reloadData];
    for(DPPDataViewCell* cell in self.visibleCells)
    {
        [self queueReusableCell:cell withIdentifier:cell.reuseIdentifier];
    }
    [self.visibleCells removeAllObjects];
    [self.visibleIndexPaths removeAllObjects];
    
    verticalLayout = (self.bounds.size.height > self.bounds.size.width);
    
    int sections = [self.dataSource numberOfSectionsInView:self];
    for(int section = 0; section < sections ; section++)
    {
        int rows = [self.dataSource view:self numberOfRowsInSection:section];
        for(int row =0 ;row <rows;row++)
        {
            //TODO:make this scrollable....
            // CGRect visibleRect = CGRectMake(self.scrollview.contentOffset.x, self.scrollview.contentOffset.y,
            //                                self.scrollview.bounds.size.width, self.scrollview.bounds.size.height);
            
            NSIndexPath* indexPath =[NSIndexPath indexPathForRow:row inSection:section];
            DPPDataViewCell* newCell = [self.dataSource view:self cellForRowAtIndexPath:indexPath];
            if(newCell.superview != self.scrollview)
            {
                [self.scrollview addSubview:newCell];
            }
            if(verticalLayout)
            {
                newCell.frame = CGRectMake(0, row*(newCell.frame.size.height),
                                           newCell.frame.size.width, newCell.frame.size.height);
            }
            else
            {
                newCell.frame = CGRectMake(row*(newCell.frame.size.width), 0,
                                       newCell.frame.size.width, newCell.frame.size.height);
            }
            [self.visibleCells addObject:newCell];
            [self.visibleIndexPaths addObject:indexPath];
        }
    }
    
    if(self.visibleCells.count >0)
    {
        DPPDataViewCell* firstCell = [self.visibleCells objectAtIndex:0];
        DPPDataViewCell* lastCell = [self.visibleCells lastObject];
        self.scrollview.contentSize = CGRectUnion(firstCell.frame, lastCell.frame).size;
    }
    else
    {
        self.scrollview.contentSize = self.scrollview.bounds.size;
    }
    if(centerCells)
    {
        [self centerScrollview];
    }
    
    pageControl.numberOfPages = self.scrollview.contentSize.width / self.scrollview.bounds.size.width;
    
    //pageControl.hidden = (pageControl.numberOfPages <= 1);
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(verticalLayout)
    {
        page = ((MAX(scrollview.contentOffset.y,0)+(scrollview.bounds.size.height*0.5)) / self.scrollview.contentSize.height) * pageControl.numberOfPages;
    }
    else
    {
        page = ((MAX(scrollview.contentOffset.x,0)+(scrollview.bounds.size.width*0.5)) / self.scrollview.contentSize.width) * pageControl.numberOfPages;
    }
    
    if(page != pageControl.currentPage)
    {
        int rows = [self.dataSource view:self numberOfRowsInSection:0];
        page = MIN(page,rows-1);
        page = MAX(page,0);
        pageControl.currentPage = page;
    }
    if(centerCells)
    {
        [self centerScrollview];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event 
{
    UIView *view = [super hitTest:point withEvent:event];
    
    if (view == self) 
        return self.scrollview;
    
    return view;
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if(self.scrollview == scrollView)
    {
        if([delegate respondsToSelector:@selector(didStartInteractionWithView:)])
        {
            [self.delegate didStartInteractionWithView:self]; 
        }
    }
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(self.scrollview == scrollView)
    {
        if([delegate respondsToSelector:@selector(didFinishInteractionWithView:)])
        {
            [self.delegate didFinishInteractionWithView:self]; 
        }
    }
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(self.scrollview == scrollView)
    {
        if([delegate respondsToSelector:@selector(didFinishAnimatingWithView:)])
        {
            [self.delegate didFinishAnimatingWithView:self];
        }
    }
}
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if(self.scrollview == scrollView)
    {
        if([delegate respondsToSelector:@selector(didFinishAnimatingWithView:)])
        {
            [self.delegate didFinishAnimatingWithView:self];
        }
    }
}

-(void)dealloc
{
    ARC_RELEASE(pageControl);
    ARC_RELEASE(tapRecog release);
    ARC_RELEASE(scrollview release);
    ARC_SUPER_DEALLOC;
}

@end
