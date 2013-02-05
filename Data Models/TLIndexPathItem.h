//
//  TLIndexPathItem.h
//  TractableLabs
//
//  Created by Tim Moose on 07/16/12.
//
//

#import <Foundation/Foundation.h>

#define TLIndexPathItemIdentifier @"identifier"
#define TLIndexPathItemSectionName @"sectionName"
#define TLIndexPathItemCellIdentifier @"cellIdentifier"

@interface TLIndexPathItem : NSObject
@property (strong, nonatomic) id identifier;
@property (strong, nonatomic) NSString *sectionName;
@property (strong, nonatomic) NSString *cellIdentifier;
@property (strong, nonatomic) id data;
- (id)initWithIdentifier:(id)identifier sectionName:(NSString *)sectionName cellIdentifier:(NSString *)cellIdentifier data:(id)data;
@end
