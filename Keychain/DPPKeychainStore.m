
#import "DPPKeychainStore.h"

//LH TODO: Upgrade to ARC

@implementation DPPKeychainStore

@synthesize serviceName;
@synthesize groupName;

+ (DPPKeychainStore *)sharedInstance
{
	static DPPKeychainStore* sharedObj=nil;
	@synchronized(self)//thread safe
	{
		if(sharedObj == nil)
		{
			sharedObj = [[DPPKeychainStore alloc] init];
		}
	}
	return sharedObj;
}

- (NSMutableDictionary *)newSearchDictionary:(NSString *)identifier 
{
	NSMutableDictionary *searchDictionary = [[NSMutableDictionary alloc] init];  
	
    [searchDictionary setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
	
    NSData *encodedIdentifier = [identifier dataUsingEncoding:NSUTF8StringEncoding];
	
    [searchDictionary setObject:encodedIdentifier forKey:(id)kSecAttrGeneric];
    [searchDictionary setObject:encodedIdentifier forKey:(id)kSecAttrAccount];
    [searchDictionary setObject:serviceName forKey:(id)kSecAttrService];
    //LH TODO: fix this..... (allow apps to sharekeychain)
   // [searchDictionary setObject:groupName forKey:(id)kSecAttrAccessGroup];
	[serviceName release];
    return searchDictionary;  //do not release as method has 'new' in title
}

- (NSData *)searchKeychainCopyMatching:(NSString *)identifier {
	
    NSMutableDictionary *searchDictionary = [self newSearchDictionary:identifier];
	
    // Add search attributes
    [searchDictionary setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
	
    // Add search return types
    [searchDictionary setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
	
    NSData *result = nil;
    OSStatus status = SecItemCopyMatching((CFDictionaryRef)searchDictionary,(CFTypeRef *)&result);
	(void)status;//prevent warning
	//DMLog(@"Keychain search Status %ld",status);
	[searchDictionary release];
    return [result autorelease];
}

- (NSString*)findKeychainValueForIdentifier:(NSString *)identifier
{
    NSString* stored = [[[NSString alloc] initWithData:[self searchKeychainCopyMatching:identifier] encoding:NSUTF8StringEncoding]  autorelease];
    if(stored.length > 0)
    {
        return stored;
    }
    return nil;
}

- (BOOL)createKeychainValue:(NSString *)password forIdentifier:(NSString *)identifier {
	NSMutableDictionary *dictionary = [self newSearchDictionary:identifier];
	
    NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
    [dictionary setObject:passwordData forKey:(id)kSecValueData];
	
    OSStatus status = SecItemAdd((CFDictionaryRef)dictionary, NULL);
    [dictionary release];
	
	if (status == errSecSuccess) {
		return YES;
    }
	
    return NO;
}

- (BOOL)updateKeychainValue:(NSString *)password forIdentifier:(NSString *)identifier {
	
    NSMutableDictionary *searchDictionary = [self newSearchDictionary:identifier];
	NSMutableDictionary *updateDictionary = [[NSMutableDictionary alloc] init];
	NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
	
    [updateDictionary setObject:passwordData forKey:(id)kSecValueData];
	
    OSStatus status = SecItemUpdate((CFDictionaryRef)searchDictionary,(CFDictionaryRef)updateDictionary);
		
    [searchDictionary release];
	
    [updateDictionary release];
	
    if (status == errSecSuccess) {
        return YES;
    }
    return NO;
}

- (void)deleteKeychainValue:(NSString *)identifier {
    NSMutableDictionary *searchDictionary = [self newSearchDictionary:identifier];
    SecItemDelete((CFDictionaryRef)searchDictionary);
    [searchDictionary release];
}





@end
