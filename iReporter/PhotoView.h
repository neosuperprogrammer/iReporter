//
//  PhotoView.h
//  iReporter
//
//  Created by Sangwook Nam on 3/26/14.
//  Copyright (c) 2014 Marin Todorov. All rights reserved.
//

#import <UIKit/UIKit.h>

//1 layout config
#define kThumbSide 90
#define kPadding 10

@protocol PhotoViewDelegate <NSObject>
-(void)didSelectPhoto:(id)sender;
@end

@interface PhotoView : UIButton

@property (assign, nonatomic) id<PhotoViewDelegate> delegate;
-(id)initWithIndex:(int)i andData:(NSDictionary*)data;

@end
