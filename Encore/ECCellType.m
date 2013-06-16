
#import "ECCellType.h"
NSString* reuseIdentifierForCellType(ECCellType type)
{
    switch (type) {
        case ECCellTypeAddFuture:
            return @"AddFutureCell";
        case ECCellTypeAddPast:
            return @"AddPastCell";
        case ECCellTypeFutureShows: //purposely left blank so goes to next one
        case ECCellTypePastShows:
            return @"HorizontalCell";
        default:
            break;
    }
}