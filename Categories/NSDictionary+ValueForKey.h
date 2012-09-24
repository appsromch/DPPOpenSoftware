//
//  NSDictionary+ValueForKey.h
//
//  Created by Lee Higgins on 12/02/2012.
//  Copyright (c) 2012 DepthPerPixel ltd. All rights reserved.
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


@end


