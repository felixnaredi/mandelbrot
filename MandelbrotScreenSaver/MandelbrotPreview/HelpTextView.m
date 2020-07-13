//
//  HelpTextView.m
//  MandelbrotPreview
//
//  Created by Felix Naredi on 2020-07-12.
//  Copyright © 2020 Felix Naredi. All rights reserved.
//

#import "HelpTextView.h"


static NSTextField * text(NSString * _Nonnull str)
{
  NSTextField * res = [NSTextField textFieldWithString:str];
  res.textColor = [NSColor colorWithWhite:1.0 alpha:1.0];
  res.font = [NSFont fontWithName:@"Menlo" size:18];
  res.editable = false;
  res.selectable = false;
  return res;
}

@implementation HelpTextView

- (id)initWithCoder:(NSCoder *)coder
{
  self = [super initWithCoder:coder];
  if (!self) { return NULL; }
  
  return self;
}

- (void)setText:(NSArray<NSString *> *)lines
{
  NSStackView * stack = [[NSStackView alloc] initWithFrame:
                         NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height)];
  
  stack.alignment = NSLayoutAttributeTop;
  stack.orientation = NSUserInterfaceLayoutOrientationVertical;
  stack.spacing = 2.0;
  
  self.subviews = @[stack];
  for (id line in lines) { [stack addArrangedSubview:text(line)]; }
}


@end
