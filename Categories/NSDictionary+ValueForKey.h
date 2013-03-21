//
//  NSDictionary+ValueForKey.h
//
//  Created by Lee Higgins on 12/02/2012.
//


#import <Foundation/Foundation.h>



@interface NSDictionary (ValueForKey)


/**
 *  Helper function to protect json parsing from having a nil value
 */
- (id)valueForKeyOrNil:(NSString *)key;


/**
 *  Helper function to protect json parsing from having a nil value and the value
 *  not being of the specified class type
 */
- (id)valueForKeyOrNil:(NSString *)key ofClass:(Class)classType;


-(BOOL)hasKey:(id)object;

// A way to update fields only if they exist and leave original if not...
-(id)updateValueIfKeyExists:(NSString*)key defaultValue:(id)originalValue;

@end


