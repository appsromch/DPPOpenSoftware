
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



@end

