//
//	Copyright 2011 James Addyman (JamSoft). All rights reserved.
//	
//	Redistribution and use in source and binary forms, with or without modification, are
//	permitted provided that the following conditions are met:
//	
//		1. Redistributions of source code must retain the above copyright notice, this list of
//			conditions and the following disclaimer.
//
//		2. Redistributions in binary form must reproduce the above copyright notice, this list
//			of conditions and the following disclaimer in the documentation and/or other materials
//			provided with the distribution.
//
//	THIS SOFTWARE IS PROVIDED BY JAMES ADDYMAN (JAMSOFT) ``AS IS'' AND ANY EXPRESS OR IMPLIED
//	WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//	FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL JAMES ADDYMAN (JAMSOFT) OR
//	CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//	SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//	ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//	NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//	ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//	The views and conclusions contained in the software and documentation are those of the
//	authors and should not be interpreted as representing official policies, either expressed
//	or implied, of James Addyman (JamSoft).
//

#import "JSTokenField.h"
#import "JSTokenButton.h"
#import <QuartzCore/QuartzCore.h>

NSString *const JSTokenFieldFrameDidChangeNotification = @"JSTokenFieldFrameDidChangeNotification";
NSString *const JSTokenFieldNewFrameKey = @"JSTokenFieldNewFrameKey";
NSString *const JSTokenFieldOldFrameKey = @"JSTokenFieldOldFrameKey";
NSString *const JSDeletedTokenKey = @"JSDeletedTokenKey";

#define HEIGHT_PADDING 3
#define WIDTH_PADDING 3

#define DEFAULT_HEIGHT 31

#define ZERO_WIDTH_SPACE_STRING @"\u200B"

@interface JSTokenField ();

- (JSTokenButton *)tokenWithString:(NSString *)string representedObject:(id)obj;
- (void)deleteHighlightedToken;

- (void)commonSetup;
@end


@implementation JSTokenField

@synthesize tokens = _tokens;
@synthesize textField = _textField;
@synthesize label = _label;
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
	if (frame.size.height < DEFAULT_HEIGHT)
	{
		frame.size.height = DEFAULT_HEIGHT;
	}
	
    if ((self = [super initWithFrame:frame]))
	{
        [self commonSetup];
    }
	
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonSetup];
    }
    return self;
}

- (void)commonSetup {
    CGRect frame = self.frame;
    [self setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0]];
    
    _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, frame.size.height)];
    [_label setBackgroundColor:[UIColor clearColor]];
    [_label setTextColor:[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0]];
    [_label setFont:[UIFont fontWithName:@"Helvetica Neue" size:17.0]];
    
    [self addSubview:_label];
    
    //		self.layer.borderColor = [[UIColor blueColor] CGColor];
    //		self.layer.borderWidth = 1.0;
    
    _tokens = [[NSMutableArray alloc] init];
    
    _hiddenTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0 , DEFAULT_HEIGHT, DEFAULT_HEIGHT)];
    [_hiddenTextField setHidden:YES];
    [_hiddenTextField setDelegate:self];
    [self addSubview:_hiddenTextField];
    [_hiddenTextField setText:ZERO_WIDTH_SPACE_STRING];
    
    frame.origin.y += HEIGHT_PADDING;
    frame.size.height -= HEIGHT_PADDING * 2;
    _textField = [[UITextField alloc] initWithFrame:frame];
    [_textField setDelegate:self];
    [_textField setBorderStyle:UITextBorderStyleNone];
    [_textField setBackground:nil];
    [_textField setBackgroundColor:[UIColor clearColor]];
    [_textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    
    //		[_textField.layer setBorderColor:[[UIColor redColor] CGColor]];
    //		[_textField.layer setBorderWidth:1.0];
    
    [_textField setText:ZERO_WIDTH_SPACE_STRING];
    
    [self addSubview:_textField];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleTextDidChange:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:_textField];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleTextDidChange:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:_hiddenTextField];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_hiddenTextField release], _hiddenTextField = nil;
	[_textField release], _textField = nil;
	[_label release], _label = nil;
	[_tokens release], _tokens = nil;
	
	[super dealloc];
}


- (void)addTokenWithTitle:(NSString *)string representedObject:(id)obj
{
	NSString *aString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
    [_textField setText:nil];
    
	if ([aString length])
	{
		JSTokenButton *token = [self tokenWithString:aString representedObject:obj];
		[_tokens addObject:token];
		
		if ([self.delegate respondsToSelector:@selector(tokenField:didAddToken:representedObject:)])
		{
			[self.delegate tokenField:self didAddToken:aString representedObject:obj];
		}
		
		[self setNeedsLayout];
	}
}

- (void)removeTokenForString:(NSString *)string
{
	for (int i = 0; i < [_tokens count]; i++)
	{
		JSTokenButton *token = [_tokens objectAtIndex:i];
		if ([[token titleForState:UIControlStateNormal] isEqualToString:string])
		{
			[token removeFromSuperview];
			[[token retain] autorelease]; // removing it from the array will dealloc the object, but we want to keep it around for the delegate method below
			[_tokens removeObject:token];
			if ([self.delegate respondsToSelector:@selector(tokenField:didRemoveToken:representedObject:)])
			{
				[self.delegate tokenField:self didRemoveTokenAtIndex:i];
			}
		}
	}
	
	[self setNeedsLayout];
}

- (void)deleteHighlightedToken
{
	for (int i = 0; i < [_tokens count]; i++)
	{
		_deletedToken = [[_tokens objectAtIndex:i] retain];
		if ([_deletedToken isToggled])
		{
			[_deletedToken removeFromSuperview];
			[_tokens removeObject:_deletedToken];
			
			if ([self.delegate respondsToSelector:@selector(tokenField:didRemoveTokenAtIndex:)])
			{
				[self.delegate tokenField:self didRemoveTokenAtIndex:i];
			}
			
			[self setNeedsLayout];	
		}
	}
}

- (JSTokenButton *)tokenWithString:(NSString *)string representedObject:(id)obj
{
	JSTokenButton *token = [JSTokenButton tokenWithString:string representedObject:obj];
	CGRect frame = [token frame];
	
	if (frame.size.width > self.frame.size.width)
	{
		frame.size.width = self.frame.size.width - (WIDTH_PADDING * 2);
	}
	
	[token setFrame:frame];
	
	[token addTarget:self
			  action:@selector(toggle:)
	forControlEvents:UIControlEventTouchUpInside];
	
	return token;
}

- (void)layoutSubviews
{
	CGRect currentRect = CGRectZero;
	
	[_label sizeToFit];
	[_label setFrame:CGRectMake(WIDTH_PADDING, HEIGHT_PADDING, [_label frame].size.width, [_label frame].size.height)];
	
	currentRect.origin.x += _label.frame.size.width + _label.frame.origin.x + WIDTH_PADDING;
	
	for (UIButton *token in _tokens)
	{
		CGRect frame = [token frame];
		
		if ((currentRect.origin.x + frame.size.width) > self.frame.size.width)
		{
			currentRect.origin = CGPointMake(WIDTH_PADDING, (currentRect.origin.y + frame.size.height + HEIGHT_PADDING));
		}
		
		frame.origin.x = currentRect.origin.x;
		frame.origin.y = currentRect.origin.y + HEIGHT_PADDING;
		
		[token setFrame:frame];
		
		if (![token superview])
		{
			[self addSubview:token];
		}
		
		currentRect.origin.x += frame.size.width + WIDTH_PADDING;
		currentRect.size = frame.size;
	}
	
	CGRect textFieldFrame = [_textField frame];
	
	textFieldFrame.origin = currentRect.origin;
	
	if ((self.frame.size.width - textFieldFrame.origin.x) >= 60)
	{
		textFieldFrame.size.width = self.frame.size.width - textFieldFrame.origin.x;
	}
	else
	{
		textFieldFrame.size.width = self.frame.size.width;
		textFieldFrame.origin = CGPointMake(_label.frame.size.width + _label.frame.origin.x + WIDTH_PADDING, (currentRect.origin.y + currentRect.size.height + HEIGHT_PADDING));
	}
	
	textFieldFrame.origin.y += HEIGHT_PADDING;
	[_textField setFrame:textFieldFrame];
	CGRect selfFrame = [self frame];
	selfFrame.size.height = textFieldFrame.origin.y + textFieldFrame.size.height + HEIGHT_PADDING;
	
	[UIView animateWithDuration:0.3
					 animations:^{
						 [self setFrame:selfFrame];
					 }
					 completion:nil];
}

- (void)toggle:(id)sender
{
	for (JSTokenButton *token in _tokens)
	{
		[token setToggled:NO];
	}
	
	JSTokenButton *token = (JSTokenButton *)sender;
	[token setToggled:YES];
	[_hiddenTextField becomeFirstResponder];
}

- (void)setFrame:(CGRect)frame
{
    CGRect oldFrame = self.frame;
    
	[super setFrame:frame];
	
	NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:[NSValue valueWithCGRect:frame] forKey:JSTokenFieldNewFrameKey];
    [userInfo setObject:[NSValue valueWithCGRect:oldFrame] forKey:JSTokenFieldOldFrameKey];
	if (_deletedToken)
	{
		[userInfo setObject:_deletedToken forKey:JSDeletedTokenKey]; 
		[_deletedToken release], _deletedToken = nil;
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:JSTokenFieldFrameDidChangeNotification object:self userInfo:[[userInfo copy] autorelease]];
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (void)handleTextDidChange:(NSNotification *)note
{
	// ensure there's always a space at the beginning
	NSMutableString *text = [[[_textField text] mutableCopy] autorelease];
	if (![text hasPrefix:ZERO_WIDTH_SPACE_STRING])
	{
		[text insertString:ZERO_WIDTH_SPACE_STRING atIndex:0];
		[_textField setText:text];
	}
    
    if (_textField == [note object]) {
        if ([self.delegate respondsToSelector:@selector(tokenFieldTextDidChange:)]) {
            [self.delegate tokenFieldTextDidChange:self];
        }
    }
    
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	if ([[textField text] isEqualToString:ZERO_WIDTH_SPACE_STRING] && [string isEqualToString:@""])
	{
		for (JSTokenButton *token in _tokens)
		{
			if ([token isToggled])
			{
				[self deleteHighlightedToken];
				[_textField becomeFirstResponder];
				return NO;
			}
		}
		
		if ([_tokens count] > 0)
		{
			if ([[_tokens lastObject] isToggled] == NO)
			{
				[[_tokens lastObject] setToggled:YES];
				[_hiddenTextField becomeFirstResponder];
				return NO;
			}
		}
		
		[self deleteHighlightedToken];
		[_textField becomeFirstResponder];
		return NO;
	}
	else if (textField == _hiddenTextField)
		return NO;
	else
	{
		if ([_tokens count] > 0)
		{
			if ([[_tokens lastObject] isHighlighted] == YES)
			{
				[[_tokens lastObject] setHighlighted:NO];
			}
		}
	}
	
	// if attempting to enter text before the intial space, disallow it, and move cursor to the end (all we can do)
	if (range.location == 0 && range.length == 0)
	{
		[_textField setText:[_textField text]];
		return NO;
	}
	
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (_textField == textField) {
        if ([self.delegate respondsToSelector:@selector(tokenFieldShouldReturn:)]) {
            return [self.delegate tokenFieldShouldReturn:self];
        }
    }
	
	return NO;
}



- (void)textFieldDidEndEditing:(UITextField *)textField
{
	if (textField == _textField)
	{
        if ([self.delegate respondsToSelector:@selector(tokenFieldDidEndEditing:)]) {
            [self.delegate tokenFieldDidEndEditing:self];
            return;
        }
        else if ([[textField text] length] > 1)
		{
			[self addTokenWithTitle:[textField text] representedObject:[textField text]];
			[textField setText:ZERO_WIDTH_SPACE_STRING];
		}
	}
	
	if (textField == _hiddenTextField)
	{
		for (JSTokenButton *token in _tokens)
		{
			[token setToggled:NO];
		}
	}
}

@end
