//
//  UIImage+tint.h
//

#import <UIKit/UIKit.h>

@interface UIImage (tint)

- (UIImage *)imageTintedWithColor:(UIColor *)color;
- (UIImage *)imageTintedWithColor:(UIColor *)color fraction:(CGFloat)fraction;

@end
