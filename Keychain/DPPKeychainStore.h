
#import <Foundation/Foundation.h>
#import <Security/Security.h>

@interface DPPKeychainStore : NSObject 
{

}

+ (DPPKeychainStore *)sharedInstance;

@property(nonatomic,copy) NSString* serviceName;
@property(nonatomic,copy)NSString* groupName;

- (NSMutableDictionary *)newSearchDictionary:(NSString *)identifier;
- (NSData *)searchKeychainCopyMatching:(NSString *)identifier;
- (NSString*)findKeychainValueForIdentifier:(NSString *)identifier;
- (BOOL)createKeychainValue:(NSString *)password forIdentifier:(NSString *)identifier;
- (BOOL)updateKeychainValue:(NSString *)password forIdentifier:(NSString *)identifier;
- (void)deleteKeychainValue:(NSString *)identifier;

@end
