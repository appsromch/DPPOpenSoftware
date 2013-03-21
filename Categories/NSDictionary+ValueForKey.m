
#import "NSDictionary+ValueForKey.h"

@implementation NSDictionary (ValueForKey)


- (id)valueForKeyOrNil:(NSString *)key { 
    if ([self valueForKey:key] != nil && [self valueForKey:key] != [NSNull null]) {
        return [self valueForKey:key];
    }
    return nil;
}


- (id)valueForKeyOrNil:(NSString *)key ofClass:(Class)classType {
    id value = [self valueForKeyOrNil:key];
    if (value && [value isKindOfClass:classType]) {
        return value;
    }
    return nil;
}

-(BOOL)hasKey:(id)object
{
    return [self objectForKey:object]!=nil;
}


-(id)updateValueIfKeyExists:(NSString*)key defaultValue:(id)originalValue
{
    if([self hasKey:key])
    {
        /*if(originalValue!=nil)
        {
            return [self valueForKeyOrNil:key ofClass:[originalValue class]];
        }
        else*/
        {
            return [self valueForKeyOrNil:key]; 
        }
    }
    return originalValue;
}




@end

