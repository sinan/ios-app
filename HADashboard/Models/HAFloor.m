#import "HAFloor.h"
#import "HASafeDict.h"

@implementation HAFloor

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _floorId = dict[@"floor_id"];
        _name = HASafeDictString(dict, @"name", _floorId);
        _level = HASafeDictInteger(dict, @"level", 0);

        // Area IDs can be in "areas" key as an array of area_id strings
        NSArray *areas = HASafeDictArrayOrNil(dict, @"areas");
        if (areas) {
            NSMutableArray *areaIds = [NSMutableArray arrayWithCapacity:areas.count];
            for (id areaEntry in areas) {
                if ([areaEntry isKindOfClass:[NSString class]]) {
                    [areaIds addObject:areaEntry];
                }
            }
            _areaIds = [areaIds copy];
        } else {
            _areaIds = @[];
        }
    }
    return self;
}

@end
