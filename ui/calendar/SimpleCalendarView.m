//
//  SimpleCalendarView.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 10. 07. 01.
//
//  last update: 2014.04.11.
//

#import "SimpleCalendarView.h"

#import "Logging.h"
#import "QuartzHelper.h"


@implementation SimpleCalendarView

@synthesize selectedYear;
@synthesize selectedMonth;
@synthesize selectedDay;
@synthesize delegate;

#pragma mark -
#pragma mark UIView

//setup calendar with given frame
- (void)setupWithFrame:(CGRect)frame
{
	//set background color
	CGColorRef bgColor = [QuartzHelper createColorRefWithR:CALENDAR_BG_COLOR_R 
														 G:CALENDAR_BG_COLOR_G 
														 B:CALENDAR_BG_COLOR_B 
														 A:1.0f];
	[self setBackgroundColor:[UIColor colorWithCGColor:bgColor]];
	CGColorRelease(bgColor);
	
	CGFloat height = frame.size.height;
	CGFloat width = frame.size.width;
	CGFloat cellWidth = width / CALENDAR_COLUMN_COUNT;
	CGFloat cellHeight = (height - CALENDAR_HEADER_HEIGHT) / CALENDAR_ROW_COUNT;
	CGFloat leftMargin = (width - cellWidth * CALENDAR_COLUMN_COUNT) / 2;
	CGFloat topMargin = (height - CALENDAR_HEADER_HEIGHT - cellHeight * CALENDAR_ROW_COUNT) / 2;
	
	//add prev/next month button
	previousMonthButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	[previousMonthButton setTitle:@"<" 
						 forState:UIControlStateNormal];
	previousMonthButton.frame = CGRectMake(leftMargin + BUTTON_SPACE, (topMargin + CALENDAR_HEADER_HEIGHT - CALENDAR_WEEKDAY_HEADER_HEIGHT - BUTTON_HEIGHT) / 2, BUTTON_WIDTH, BUTTON_HEIGHT);
	[previousMonthButton addTarget:self 
							action:@selector(gotoPreviousMonth:) 
				  forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:previousMonthButton];
	nextMonthButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	[nextMonthButton setTitle:@">" 
					 forState:UIControlStateNormal];
	nextMonthButton.frame = CGRectMake(width - BUTTON_SPACE - BUTTON_WIDTH, (topMargin + CALENDAR_HEADER_HEIGHT - CALENDAR_WEEKDAY_HEADER_HEIGHT - BUTTON_HEIGHT) / 2, BUTTON_WIDTH, BUTTON_HEIGHT);
	[nextMonthButton addTarget:self 
						action:@selector(gotoNextMonth:) 
			  forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:nextMonthButton];
	
	//add month label
	monthLabel = [[UILabel alloc] initWithFrame:CGRectMake((width - MONTH_LABEL_WIDTH) / 2, (topMargin + CALENDAR_HEADER_HEIGHT - CALENDAR_WEEKDAY_HEADER_HEIGHT - MONTH_LABEL_HEIGHT) / 2, MONTH_LABEL_WIDTH, MONTH_LABEL_HEIGHT)];
	monthLabel.text = [NSString stringWithFormat:@"%04d / %02d", 1981, 6];
	monthLabel.textAlignment = NSTextAlignmentCenter;
	monthLabel.textColor = [UIColor colorWithRed:MONTH_LABEL_FG_COLOR_R 
										   green:MONTH_LABEL_FG_COLOR_G 
											blue:MONTH_LABEL_FG_COLOR_B 
										   alpha:1.0f];
	monthLabel.font = [UIFont fontWithName:MONTH_LABEL_FONT 
									  size:MONTH_LABEL_FONT_SIZE];
	monthLabel.backgroundColor = [UIColor clearColor];	//transparent
	[self addSubview:monthLabel];
	
	//add weekday header labels
	NSArray* weekDays = [NSArray arrayWithObjects:WEEKDAY_LABEL_SUNDAY, WEEKDAY_LABEL_MONDAY, WEEKDAY_LABEL_TUESDAY, WEEKDAY_LABEL_WEDNESDAY, WEEKDAY_LABEL_THURSDAY, WEEKDAY_LABEL_FRIDAY, WEEKDAY_LABEL_SATURDAY, nil];
	for(int i=0; i<CALENDAR_COLUMN_COUNT; i++)
	{
		UILabel* weekday = [[UILabel alloc] initWithFrame:CGRectMake(leftMargin + (i * cellWidth), 
																	 CALENDAR_HEADER_HEIGHT - CALENDAR_WEEKDAY_HEADER_HEIGHT + topMargin, 
																	 cellWidth, 
																	 CALENDAR_WEEKDAY_HEADER_HEIGHT)];
		weekday.text = [weekDays objectAtIndex:i];
		weekday.textAlignment = NSTextAlignmentRight;
		weekday.backgroundColor = [UIColor clearColor];
		switch(i)
		{
			case 0:	//Sunday
				weekday.textColor = [UIColor colorWithRed:WEEKDAY_LABEL_SUNDAY_COLOR_R 
													green:WEEKDAY_LABEL_SUNDAY_COLOR_G 
													 blue:WEEKDAY_LABEL_SUNDAY_COLOR_B 
													alpha:1.0f];
				break;
			case 6:	//Saturday
				weekday.textColor = [UIColor colorWithRed:WEEKDAY_LABEL_SATURDAY_COLOR_R 
													green:WEEKDAY_LABEL_SATURDAY_COLOR_G 
													 blue:WEEKDAY_LABEL_SATURDAY_COLOR_B 
													alpha:1.0f];
				break;
			default:
				weekday.textColor = [UIColor colorWithRed:WEEKDAY_LABEL_OTHERDAY_COLOR_R 
													green:WEEKDAY_LABEL_OTHERDAY_COLOR_G 
													 blue:WEEKDAY_LABEL_OTHERDAY_COLOR_B 
													alpha:1.0f];
				break;
		}
		weekday.font = [UIFont fontWithName:WEEKDAY_LABEL_FONT 
									   size:WEEKDAY_LABEL_FONT_SIZE];
		[self addSubview:weekday];
		[weekday release];
	}
	
	//add calendar cell views
	cells = [[NSMutableArray alloc] init];
	for(int i=0; i<CALENDAR_ROW_COUNT; i++)
	{
		for(int j=0; j<CALENDAR_COLUMN_COUNT; j++)
		{
			SimpleCalendarCellView* cell = [[SimpleCalendarCellView alloc] initWithFrame:CGRectMake(leftMargin + (j * cellWidth), 
																									CALENDAR_HEADER_HEIGHT + topMargin + (i * cellHeight), 
																									cellWidth, 
																									cellHeight)];
			
			//add target
			[cell addTarget:self action:@selector(cellPressed:) forControlEvents:UIControlEventTouchUpInside];
			
			[cells addObject:cell];
			[self addSubview:cell];
			[cell release];
		}
	}
	
	//set delegate
	delegate = nil;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if((self = [super initWithCoder:aDecoder]))
	{
        // Initialization code
		[self setupWithFrame:self.frame];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
	{
        // Initialization code
		[self setupWithFrame:frame];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


#pragma mark -
#pragma mark calendar-manipulating functions

+ (NSDateComponents*)dateCompWithDayAdded:(int)dayAdded toYear:(uint)year month:(uint)month day:(uint)day
{
	//get date from last selected date
	NSCalendar* calendar = [NSCalendar autoupdatingCurrentCalendar];
	NSDateComponents* dateComp = [[NSDateComponents alloc] init];
	[dateComp setYear:year];
	[dateComp setMonth:month];
	[dateComp setDay:day];
	
	//get date from newly selected date
	NSDate* selectedDate = [calendar dateFromComponents:dateComp];
	[dateComp release];
	dateComp = [[NSDateComponents alloc] init];
	[dateComp setDay:dayAdded];
	NSDate* addedDay = [calendar dateByAddingComponents:dateComp 
												 toDate:selectedDate 
												options:0];
	[dateComp release];
	
	//return added date component
	return [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit 
					   fromDate:addedDay];
}

+ (NSDateComponents*)dateCompWithMonthAdded:(int)monthAdded toYear:(uint)year month:(uint)month day:(uint)day
{
	//get date from last selected date
	NSCalendar* calendar = [NSCalendar autoupdatingCurrentCalendar];
	NSDateComponents* dateComp = [[NSDateComponents alloc] init];
	[dateComp setYear:year];
	[dateComp setMonth:month];
	[dateComp setDay:day];
	
	//get date from newly selected date
	NSDate* selectedDate = [calendar dateFromComponents:dateComp];
	[dateComp release];
	dateComp = [[NSDateComponents alloc] init];
	[dateComp setMonth:monthAdded];
	NSDate* addedMonth = [calendar dateByAddingComponents:dateComp 
												   toDate:selectedDate 
												  options:0];
	[dateComp release];
	
	//return added date component
	return [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit 
					   fromDate:addedMonth];
}

+ (NSDateComponents*)dateCompWithYearAdded:(int)yearAdded toYear:(uint)year month:(uint)month day:(uint)day
{
	//get date from last selected date
	NSCalendar* calendar = [NSCalendar autoupdatingCurrentCalendar];
	NSDateComponents* dateComp = [[NSDateComponents alloc] init];
	[dateComp setYear:year];
	[dateComp setMonth:month];
	[dateComp setDay:day];
	
	//get date from newly selected date
	NSDate* selectedDate = [calendar dateFromComponents:dateComp];
	[dateComp release];
	dateComp = [[NSDateComponents alloc] init];
	[dateComp setYear:yearAdded];
	NSDate* addedYear = [calendar dateByAddingComponents:dateComp 
												  toDate:selectedDate 
												 options:0];
	[dateComp release];
	
	//return added date component
	return [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit 
					   fromDate:addedYear];
}

- (void)gotoPreviousDay:(id)sender
{
	//DebugLog(@"previous day!");
	
	//refresh
	NSDateComponents* dateComp = [SimpleCalendarView dateCompWithDayAdded:-1 
																   toYear:selectedYear 
																	month:selectedMonth 
																	  day:selectedDay];
	[self refreshWithYear:(int)[dateComp year]
					month:(int)[dateComp month]
					  day:(int)[dateComp day]];
}

- (void)gotoNextDay:(id)sender
{
	//DebugLog(@"next day!");
	
	//refresh
	NSDateComponents* dateComp = [SimpleCalendarView dateCompWithDayAdded:+1 
																   toYear:selectedYear 
																	month:selectedMonth 
																	  day:selectedDay];
	[self refreshWithYear:(int)[dateComp year]
					month:(int)[dateComp month]
					  day:(int)[dateComp day]];
}

- (void)gotoPreviousMonth:(id)sender
{
	//DebugLog(@"previous month!");
	
	//refresh
	NSDateComponents* dateComp = [SimpleCalendarView dateCompWithMonthAdded:-1 
																	 toYear:selectedYear 
																	  month:selectedMonth 
																		day:selectedDay];
	[self refreshWithYear:(int)[dateComp year]
					month:(int)[dateComp month]
					  day:(int)[dateComp day]];
}

- (void)gotoNextMonth:(id)sender
{
	//DebugLog(@"next month!");
	
	//refresh
	NSDateComponents* dateComp = [SimpleCalendarView dateCompWithMonthAdded:+1 
																	 toYear:selectedYear 
																	  month:selectedMonth 
																		day:selectedDay];
	[self refreshWithYear:(int)[dateComp year]
					month:(int)[dateComp month]
					  day:(int)[dateComp day]];
}

- (void)gotoPreviousYear:(id)sender
{
	//DebugLog(@"previous year!");
	
	//refresh
	NSDateComponents* dateComp = [SimpleCalendarView dateCompWithYearAdded:-1 
																	toYear:selectedYear 
																	 month:selectedMonth 
																	   day:selectedDay];
	[self refreshWithYear:(int)[dateComp year]
					month:(int)[dateComp month]
					  day:(int)[dateComp day]];
}

- (void)gotoNextYear:(id)sender
{
	//DebugLog(@"next year!");
	
	//refresh
	NSDateComponents* dateComp = [SimpleCalendarView dateCompWithYearAdded:+1 
																	toYear:selectedYear 
																	 month:selectedMonth 
																	   day:selectedDay];
	[self refreshWithYear:(int)[dateComp year]
					month:(int)[dateComp month]
					  day:(int)[dateComp day]];
}

- (void)refresh;	//refresh calendar for today
{
	int year, month, day;
	NSDateComponents* dateComp = [[NSCalendar autoupdatingCurrentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
	year = (int)[dateComp year];
	month = (int)[dateComp month];
	day = (int)[dateComp day];
	
	[self refreshWithYear:year month:month day:day];
}

- (void)refreshWithYear:(int)year month:(int)month day:(int)day
{
	selectedYear = year;
	selectedMonth = month;
	selectedDay = day;
	
	//update year-month label
	monthLabel.text = [NSString stringWithFormat:@"%04d / %02d", selectedYear, selectedMonth];

	NSCalendar* calendar = [NSCalendar autoupdatingCurrentCalendar];
	
	//DebugLog(@"selected year = %d, month = %d, day = %d", selectedYear, selectedMonth, selectedDay);

	//calculate first day of given month
	NSDateComponents* dateComp = [[NSDateComponents alloc] init];
	[dateComp setYear:selectedYear];
	[dateComp setMonth:selectedMonth];
	[dateComp setDay:1];
	NSDate* day1 = [calendar dateFromComponents:dateComp];
	int firstWeekday = (int)[[calendar components:NSWeekdayCalendarUnit fromDate:day1] weekday];
	[dateComp release];

	//DebugLog(@"first week day of this month = %d, %@", firstWeekday, day1);

	//calculate number of days in previous month
	dateComp = [[NSDateComponents alloc] init];
	[dateComp setMonth:-1];
	NSDate* previousMonth = [calendar dateByAddingComponents:dateComp 
													  toDate:day1 
													 options:0];
	NSRange range = [calendar rangeOfUnit:NSDayCalendarUnit 
								   inUnit:NSMonthCalendarUnit 
								  forDate:previousMonth];
	int numDaysOfPrevMonth = (int)range.length;
	range = [calendar rangeOfUnit:NSDayCalendarUnit 
						   inUnit:NSMonthCalendarUnit 
						  forDate:day1];
	int numDaysOfCurrentMonth = (int)range.length;
	[dateComp release];

	//DebugLog(@"number of days in current/previous month = %d/%d", numDaysOfCurrentMonth, numDaysOfPrevMonth);
	
	//setup calendar cells
	int cellIndex = 0;
	int dayNumberBase;
	for(SimpleCalendarCellView* cell in cells)
	{
		dayNumberBase = (cellIndex + 1) - (firstWeekday - 1);

		if(cellIndex + 1 < firstWeekday)	//days of previous month
		{
			[cell setCellType:CalendarCellTypePreviousMonth 
				   cellStatus:CalendarCellStatusNone 
						  day:dayNumberBase + numDaysOfPrevMonth];
		}
		else if(cellIndex + 1 > firstWeekday - 1 + numDaysOfCurrentMonth)	//days of next month
		{
			[cell setCellType:CalendarCellTypeNextMonth 
				   cellStatus:CalendarCellStatusNone 
						  day:dayNumberBase - numDaysOfCurrentMonth];
		}
		else	//days of current month
		{
			if(dayNumberBase == selectedDay)
			{
				[cell setCellType:CalendarCellTypeCurrentMonth 
					   cellStatus:CalendarCellStatusSelected 
							  day:dayNumberBase];
				currentSelectedCell = cell;
				
				//send a notification to the delegate
				[delegate calendar:self 
				   cellWasSelected:cell];
			}
			else
			{
				[cell setCellType:CalendarCellTypeCurrentMonth 
					   cellStatus:CalendarCellStatusNone 
							  day:dayNumberBase];
			}
		}
		
		cellIndex ++;
	}
}


#pragma mark -
#pragma mark functions for event processing

- (void)cellPressed:(id)sender
{
	//DebugLog(@"cell pressed: %@", sender);

	if([sender cellType] == CalendarCellTypePreviousMonth)
	{
		NSDateComponents* dateComp = [SimpleCalendarView dateCompWithMonthAdded:-1 
																		 toYear:selectedYear 
																		  month:selectedMonth 
																			day:1];
		
		//move to previous month & selected day
		[self refreshWithYear:(int)[dateComp year]
						month:(int)[dateComp month]
						  day:[(SimpleCalendarCellView*)sender day]];
	}
	else if([sender cellType] == CalendarCellTypeNextMonth)
	{
		NSDateComponents* dateComp = [SimpleCalendarView dateCompWithMonthAdded:+1 
																		 toYear:selectedYear 
																		  month:selectedMonth 
																			day:1];
		
		//move to next month & selected day
		[self refreshWithYear:(int)[dateComp year]
						month:(int)[dateComp month]
						  day:[(SimpleCalendarCellView*)sender day]];
	}
	else	//if([pressed cellType] == CalendarCellTypeCurrentMonth)
	{
		lastSelectedCell = currentSelectedCell;
		currentSelectedCell = sender;
		selectedDay = [(SimpleCalendarCellView*)sender day];

		[lastSelectedCell setCellStatus:CalendarCellStatusNone];
		[currentSelectedCell setCellStatus:CalendarCellStatusSelected];
		
		//send a notification to the delegate
		[delegate calendar:self 
		   cellWasSelected:sender];
	}
}


#pragma mark -
#pragma mark memory management

- (void)dealloc {

	[cells release];
	[previousMonthButton release];
	[nextMonthButton release];
	[monthLabel release];
	
    [super dealloc];
}


@end
