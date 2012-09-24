

#import <Foundation/Foundation.h>
#import "DPPDataViewCell.h"
@class DPPDataView;

@protocol DPPDataViewDataSource<NSObject>

@required

- (NSInteger)view:(DPPDataView *)view numberOfRowsInSection:(NSInteger)section;

- (DPPDataViewCell *)view:(DPPDataView *)view cellForRowAtIndexPath:(NSIndexPath *)indexPath;

- (NSInteger)numberOfSectionsInView:(DPPDataView *)view;

//- (NSString *)view:(UIDataView *)view titleForHeaderInSection:(NSInteger)section;  //TODO
//- (NSString *)view:(UIDataView *)view titleForFooterInSection:(NSInteger)section;

@end
