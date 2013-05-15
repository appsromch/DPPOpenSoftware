

#import "DPPNibInstanceView.h"
#import "WeakReference.h"

@implementation DPPNibInstanceView

// LH queue system
// We keep a list of in use and not in use views based on nib name
// when we dequeue we grab from the not in-use list or create a new instance and place this in the in-use list.
// views must be returned to the system when they are finished with using enqueue. Here we remove from the in-use list and
// add to the not inuse list. The nib name acts as the reuseidentifier.

static NSMutableDictionary* instancesNotInUse =nil;
static NSMutableDictionary* instancesInUse = nil;


+(void)initialize
{
    [super initialize];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(memoryWarning)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}
+(id)instanceFromNib:(NSString*)nibName
{
    NSArray* views = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
    
    for (UIView* view in views)
    {
        if([view isKindOfClass:[self class]])
        {
            return view;
        }
    }
    return nil;
}

+(void)memoryWarning
{
    for(id key in instancesInUse.allKeys)
    {
        NSMutableSet* notInUse = [instancesNotInUse objectForKey:key];
        [notInUse removeAllObjects];
    }
}

+(void)enqueueInstance:(id)object
{
    if(instancesNotInUse == nil)
    {
        instancesNotInUse = [NSMutableDictionary dictionary];
    }
    
    for(id key in instancesInUse.allKeys)
    {
        NSMutableSet* inuse = [instancesInUse objectForKey:key];
        WeakReference* weakObject = [WeakReference weakReferenceWithObject:object];
        if([inuse containsObject:weakObject])
        {
            NSMutableSet* notInuse = [instancesNotInUse objectForKey:key];
            
            if(notInuse==nil)
            {
                notInuse = [NSMutableSet setWithObject:weakObject];
                [instancesNotInUse setObject:notInuse forKey:key];
            }
            else
            {
                [notInuse addObject:weakObject];
            }
            
            [inuse removeObject:weakObject];
            
            for(WeakReference* weakObject in inuse.copy)
            {//LH clean any dead ref's
                if(weakObject.nonretainedObjectValue == nil)
                {
                    [inuse removeObject:weakObject];
                     NSLog(@"cleaned instance %@",key);
                }
            }
            
             NSLog(@"recycled instance %@(%d)",key,instancesNotInUse.count);
            break;
        }
    }

}

+(id)dequeueInstanceFormNib:(NSString*)nibName
{
    if(instancesInUse == nil)
    {
        instancesInUse = [NSMutableDictionary dictionary];
    }
    
    NSMutableSet* notInuse = [instancesNotInUse objectForKey:nibName];
    NSMutableSet* inuse = [instancesInUse objectForKey:nibName];
    
    //we keep a weak reference on the in-use list as the client could never give back the view...
    WeakReference* weakObject = [notInuse anyObject];
    
    if(weakObject == nil)
    {
        id newInstance = [self instanceFromNib:nibName];
        weakObject = [WeakReference weakReferenceWithObject:newInstance];
        if(inuse == nil)
        {
            inuse = [NSMutableSet setWithObject:weakObject];
            [instancesInUse setObject:inuse forKey:nibName];
        }
        else
        {
            [inuse addObject:weakObject];
        }
        NSLog(@"New instance %@(%d)",nibName,inuse.count);
    }
    else
    {
        [inuse addObject:weakObject];
        [notInuse removeObject:weakObject];
        NSLog(@"cached instance %@(%d)",nibName,inuse.count);
    }
    return weakObject.nonretainedObjectValue;
}

-(id)replaceWithNibInstance:(NSString*)nibName
{ //LH replace my view with the one from the nib..
    UIView* nibInstance = [[self class] instanceFromNib:nibName];
    if(nibInstance)
    {
        nibInstance.frame = self.frame;
        [self.superview insertSubview:nibInstance aboveSubview:self];
        [self removeFromSuperview];
    }
    return nibInstance;
}



@end
