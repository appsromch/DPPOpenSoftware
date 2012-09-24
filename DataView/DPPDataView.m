

#import "DPPDataView.h"
#import "DPPARCCompatibility.h"
@interface  DPPDataView()
@property(nonatomic,retain) NSMutableDictionary* reusableCells;
@property(nonatomic,assign) BOOL invalid;
@end

@implementation DPPDataView

@synthesize reusableCells;
@synthesize delegate;
@synthesize dataSource;
@synthesize visibleCells;
@synthesize visibleIndexPaths;
@synthesize selectedIndexPath;
@synthesize invalid;

-(id)init
{
    self = [super init];
    if(self)
    {
        invalid =YES;
        [self performSelector:@selector(reloadData) withObject:nil afterDelay:0.0];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self= [super initWithCoder:aDecoder];
    if(self)
    {
        invalid=YES;
        [self performSelector:@selector(reloadData) withObject:nil afterDelay:0.0];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self performSelector:@selector(reloadData) withObject:nil afterDelay:0.0];
    }
    return self;
}

-(void)drawRect:(CGRect)rect
{
    if(invalid)
    {
        [self reloadData];
    }
    [super drawRect:rect];
}

-(void)reloadData
{
    [self deSelectRowAtIndexPath:nil];
    [self selectRowAtIndexPath:selectedIndexPath];
    [self setNeedsLayout];
    invalid=NO;
}

-(void)queueReusableCell:(DPPDataViewCell*)cell withIdentifier:(NSString*)identifier
{
    NSMutableArray* reusable = [self.reusableCells objectForKey:identifier];
    
    if(reusable)
    {
        [reusable addObject:cell];
    }
    else
    {
        if(!reusableCells)
        {
            self.reusableCells = [NSMutableDictionary dictionary];
        }
        [reusableCells setObject:[NSMutableArray arrayWithObject:cell] forKey:identifier];
    }
    
    [cell removeFromSuperview];
}

-(NSMutableArray*)visibleCells
{
    if(!visibleCells)
    {
        visibleCells = ARC_RETAIN([NSMutableArray array]);
    }
    return visibleCells;
}

-(NSMutableArray*)visibleIndexPaths
{
    if(!visibleIndexPaths)
    {
        visibleIndexPaths = ARC_RETAIN([NSMutableArray array]);
    }
    return visibleIndexPaths; 
}

-(void)selectRowAtIndexPath:(NSIndexPath*)indexPath
{
    for(int i=0;i<visibleIndexPaths.count;i++)
    {
        NSIndexPath* idx = [visibleIndexPaths objectAtIndex:i];
        if([idx isEqual:indexPath])
        {
            DPPDataViewCell* cell = [visibleCells objectAtIndex:i];
            cell.selected = YES;
            [cell.superview bringSubviewToFront:cell];
            self.selectedIndexPath = indexPath;
            break;
        }
    }
}

-(void)deSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    for(int i=0;i<visibleIndexPaths.count;i++)
    {
        NSIndexPath* idx = [visibleIndexPaths objectAtIndex:i];
        if([idx isEqual:indexPath] || indexPath == nil)
        {
            DPPDataViewCell* cell = [visibleCells objectAtIndex:i];
            cell.selected = NO;
        }
    }
    self.selectedIndexPath = nil;
}

-(void)setDataSource:(id<DPPDataViewDataSource>)newDataSource
{
    invalid = invalid | (dataSource!=newDataSource);
    dataSource = newDataSource;
}

-(DPPDataViewCell*)dequeueReusableCellWithIdentifier:(NSString*)identifier
{
    NSMutableArray* reuseable = [self.reusableCells objectForKey:identifier];
    DPPDataViewCell* retCell = ARC_RETAIN([reuseable lastObject]);
    if(reuseable.count > 0)
    { //lower OS's use object at index 0 for next call !
        [reuseable removeLastObject];
    }
    return ARC_AUTORELEASE(retCell);
}

-(void)dealloc
{
    ARC_RELEASE(reusableCells);
    ARC_RELEASE(visibleCells);
    ARC_RELEASE(visibleIndexPaths);
    ARC_RELEASE(selectedIndexPath);
    ARC_SUPER_DEALLOC;
}

@end
