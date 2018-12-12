

#import "TextFieldNameCell.h"

@implementation TextFieldNameCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
   // _rightTextTextField.placeholder=@"Cantidad de acompañante";
   
    // Configure the view for the selected state
}

//-(void)awakeFromNib{
//    CATransform3D transform = _rightTextTextField.layer.sublayerTransform;
//    CATransform3D translate = CATransform3DMakeTranslation(5, 0, 0);
//    _rightTextTextField.layer.sublayerTransform = CATransform3DConcat(transform, translate);
//}


@end
