

#import "DPPNibInstanceView.h"

@implementation DPPNibInstanceView

// LH queue system
// We keep a list of in use and not in use views based on nib name
// when we dequeue we grab from the not in-use list or create a new instance and place this in the in-use list.
// views must be returned to the system when they are finished with using enqueue. Here we remove from the in-use list and
// add to the not inuse list. The nib name acts as the reuseidentifier.

static NSMutableDictionary* instancesNotInUse =nil;
static NSMutableDictionary* instancesInUse = nil;

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

+(void)enqueueInstance:(id)object
{
    if(instancesNotInUse == nil)
    {
        instancesNotInUse = [NSMutableDictionary dictionary];
    }
    
    for(id key in instancesInUse.allKeys)
    {
        NSMutableSet* inuse = [instancesInUse objectForKey:key];
        if([inuse containsObject:object])
        {
            NSMutableSet* notInuse = [instancesNotInUse objectForKey:key];
            if(notInuse==nil)
            {
                notInuse = [NSMutableSet setWithObject:object];
                [instancesNotInUse setObject:notInuse forKey:key];
            }
            else
            {
                [notInuse addObject:object];
            }
            [inuse removeObject:object];
             NSLog(@"recycled instance %@(%d)",key,instancesNotInUse.count);
            break;
        }
        else
        {
             NSLog(@"not for this recycle bin! %@",object);
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
    
    id cachedInstance = [notInuse anyObject];
    
    if(cachedInstance == nil)
    {
        cachedInstance = [self instanceFromNib:nibName];
        if(inuse == nil)
        {
            inuse = [NSMutableSet setWithObject:cachedInstance];
            [instancesInUse setObject:inuse forKey:nibName];
        }
        else
        {
            [inuse addObject:cachedInstance];
        }
        NSLog(@"New instance %@(%d)",nibName,inuse.count);
    }
    else
    {
        [inuse addObject:cachedInstance];
        [notInuse removeObject:cachedInstance];
        NSLog(@"cached instance %@(%d)",nibName,inuse.count);
    }
    return cachedInstance;
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
