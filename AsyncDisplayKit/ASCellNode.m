/* Copyright (c) 2014-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "ASCellNode+Internal.h"

#import "ASInternalHelpers.h"
#import "ASCollectionView.h"
#import <AsyncDisplayKit/_ASDisplayView.h>
#import <AsyncDisplayKit/ASDisplayNode+Subclasses.h>
#import <AsyncDisplayKit/ASTextNode.h>

#import <AsyncDisplayKit/ASInsetLayoutSpec.h>

#pragma mark -
#pragma mark ASCellNode

@interface ASCellNode ()
{
  UIViewController *_viewController;
  ASDisplayNode *_viewControllerNode;
}

@end

@implementation ASCellNode

- (instancetype)init
{
  if (!(self = [super init]))
    return nil;

  // Use UITableViewCell defaults
  _selectionStyle = UITableViewCellSelectionStyleDefault;
  self.clipsToBounds = YES;
  if ([self.layoutDelegate respondsToSelector:@selector(visibleNodeDidScroll:inScrollView:withCellFrame:)]) {
     self.shouldObserveVisibility= YES;
  }
  return self;
}

- (instancetype)initWithViewControllerBlock:(ASDisplayNodeViewControllerBlock)viewControllerBlock didLoadBlock:(ASDisplayNodeDidLoadBlock)didLoadBlock
{
  if (!(self = [super init]))
    return nil;
  
  ASDisplayNodeAssertNotNil(viewControllerBlock, @"should initialize with a valid block that returns a UIViewController");
  
  if (viewControllerBlock) {
    
    _viewControllerNode = [[ASDisplayNode alloc] initWithViewBlock:^UIView *{
      _viewController = viewControllerBlock();
      return _viewController.view;
    } didLoadBlock:didLoadBlock];
    
    [self addSubnode:_viewControllerNode];
  }
  
  if ([self.layoutDelegate respondsToSelector:@selector(visibleNodeDidScroll:inScrollView:withCellFrame:)]) {
    self.shouldObserveVisibility = YES;
  }
  return self;
}

- (void)layout
{
  [super layout];
  
  _viewControllerNode.frame = self.bounds;
}

- (void)layoutDidFinish
{
  [super layoutDidFinish];

  _viewControllerNode.frame = self.bounds;
}

- (instancetype)initWithLayerBlock:(ASDisplayNodeLayerBlock)viewBlock didLoadBlock:(ASDisplayNodeDidLoadBlock)didLoadBlock
{
  ASDisplayNodeAssertNotSupported();
  return nil;
}

- (instancetype)initWithViewBlock:(ASDisplayNodeViewBlock)viewBlock didLoadBlock:(ASDisplayNodeDidLoadBlock)didLoadBlock
{
  ASDisplayNodeAssertNotSupported();
  return nil;
}

- (void)setLayerBacked:(BOOL)layerBacked
{
  // ASRangeController expects ASCellNodes to be view-backed.  (Layer-backing is supported on ASCellNode subnodes.)
  ASDisplayNodeAssert(!layerBacked, @"ASCellNode does not support layer-backing.");
}

- (void)setNeedsLayout
{
  ASDisplayNodeAssertThreadAffinity(self);  
  CGSize oldSize = self.calculatedSize;
  [super setNeedsLayout];

  if (_layoutDelegate != nil) {
    BOOL sizeChanged = !CGSizeEqualToSize(oldSize, self.calculatedSize);
    ASPerformBlockOnMainThread(^{
      [_layoutDelegate nodeDidRelayout:self sizeChanged:sizeChanged];
    });
  }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  ASDisplayNodeAssertMainThread();
  ASDisplayNodeAssert([self.view isKindOfClass:_ASDisplayView.class], @"ASCellNode views must be of type _ASDisplayView");
  [(_ASDisplayView *)self.view __forwardTouchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  ASDisplayNodeAssertMainThread();
  ASDisplayNodeAssert([self.view isKindOfClass:_ASDisplayView.class], @"ASCellNode views must be of type _ASDisplayView");
  [(_ASDisplayView *)self.view __forwardTouchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  ASDisplayNodeAssertMainThread();
  ASDisplayNodeAssert([self.view isKindOfClass:_ASDisplayView.class], @"ASCellNode views must be of type _ASDisplayView");
  [(_ASDisplayView *)self.view __forwardTouchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
  ASDisplayNodeAssertMainThread();
  ASDisplayNodeAssert([self.view isKindOfClass:_ASDisplayView.class], @"ASCellNode views must be of type _ASDisplayView");
  [(_ASDisplayView *)self.view __forwardTouchesCancelled:touches withEvent:event];
}

<<<<<<< HEAD
- (void)updateScrollSituationWithScrollVIew:(UIScrollView *)scrollView
{
    // TODO(Max): Fix the cellFrame here
    [self.layoutDelegate scrollViewDidScroll:scrollView cellFrameInScrollView:CGRectZero];
=======
- (void)_visibleNodeDidScroll:(UIScrollView *)scrollView withCellFrame:(CGRect)cellFrame
{
  if (layoutDelegateImplementsVisibleNodeDidScroll) {
    [self.layoutDelegate visibleNodeDidScroll:self inScrollView:scrollView withCellFrame:cellFrame];
  }
>>>>>>> 4b8216f... Adding scroll visibility
}

@end


#pragma mark -
#pragma mark ASTextCellNode

@interface ASTextCellNode ()
{
  NSString *_text;
  ASTextNode *_textNode;
}

@end


@implementation ASTextCellNode

static const CGFloat kFontSize = 18.0f;

- (instancetype)init
{
  if (!(self = [super init]))
    return nil;
  
  _text = @"";
  _textNode = [[ASTextNode alloc] init];
  [self addSubnode:_textNode];

  return self;
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize
{
  static const CGFloat kHorizontalPadding = 15.0f;
  static const CGFloat kVerticalPadding = 11.0f;
  UIEdgeInsets insets = UIEdgeInsetsMake(kVerticalPadding, kHorizontalPadding, kVerticalPadding, kHorizontalPadding);
  return [ASInsetLayoutSpec insetLayoutSpecWithInsets:insets child:_textNode];
}

- (void)setText:(NSString *)text
{
  if (_text == text)
    return;

  _text = [text copy];
  _textNode.attributedString = [[NSAttributedString alloc] initWithString:_text
                                                               attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:kFontSize]}];
  [self setNeedsLayout];
}

@end
