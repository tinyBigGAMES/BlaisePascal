{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

program ProgramTested;

uses
  //UTestbed;
  Types,
  SysUtils,
  StrUtils,
  DateUtils;

procedure TestDateUtils();  
var
  LNow: TDateTime;
  LFormatted: String;
  LYear: Integer;
  LMonth: Integer;
  LDay: Integer;
  LDate1: TDateTime;
  LDate2: TDateTime;
  
begin
  WriteLn('=== Testing DateUtils ===');
  WriteLn();
  
  LNow := Now();
  
  // Test DecodeDate
  DecodeDate(LNow, LYear, LMonth, LDay);
  WriteLn('Current Date:');
  WriteLn('Year: ', LYear);
  WriteLn('Month: ', LMonth);
  WriteLn('Day: ', LDay);
  WriteLn();
  
  // Test FormatDateTime with various formats
  LFormatted := FormatDateTime('dddd, mmmm d, yyyy', LNow);
  WriteLn('Full format: ', LFormatted);
  
  LFormatted := FormatDateTime('mm/dd/yyyy hh:nn:ss', LNow);
  WriteLn('Numeric format: ', LFormatted);
  
  LFormatted := FormatDateTime('ddd, mmm d, yyyy', LNow);
  WriteLn('Abbreviated format: ', LFormatted);
  WriteLn();
  
  // Test date arithmetic
  LDate1 := EncodeDate(2025, 1, 1);
  LDate2 := EncodeDate(2025, 12, 31);
  WriteLn('Days between Jan 1 and Dec 31, 2025: ', DaysBetween(LDate1, LDate2));
  
  // Test leap year
  WriteLn('Is 2024 a leap year? ', IsLeapYear(2024));
  WriteLn('Is 2025 a leap year? ', IsLeapYear(2025));
  WriteLn();
end;

procedure TestStrUtils();
var
  LText: String;
  LResult: String;
  
begin
  WriteLn('=== Testing StrUtils ===');
  WriteLn();
  
  LText := 'Hello World';
  
  // Test string reversal
  LResult := ReverseString(LText);
  WriteLn('Original: ', LText);
  WriteLn('Reversed: ', LResult);
  WriteLn();
  
  // Test LeftStr and RightStr
  WriteLn('LeftStr("', LText, '", 5): ', LeftStr(LText, 5));
  WriteLn('RightStr("', LText, '", 5): ', RightStr(LText, 5));
  WriteLn();
  
  // Test ContainsStr
  WriteLn('ContainsStr("', LText, '", "World"): ', ContainsStr(LText, 'World'));
  WriteLn('ContainsStr("', LText, '", "Test"): ', ContainsStr(LText, 'Test'));
  WriteLn();
  
  // Test StartsStr and EndsStr
  WriteLn('StartsStr("Hello", "', LText, '"): ', StartsStr('Hello', LText));
  WriteLn('EndsStr("World", "', LText, '"): ', EndsStr('World', LText));
  WriteLn();
  
  // Test DupeString
  LResult := DupeString('*', 10);
  WriteLn('DupeString("*", 10): ', LResult);
  WriteLn();
  
  // Test PadLeft and PadRight
  WriteLn('PadLeft("123", 10): [', PadLeft('123', 10), ']');
  WriteLn('PadRight("123", 10): [', PadRight('123', 10), ']');
  WriteLn();
end;

procedure TestTypes();
var
  LPoint1: TPoint;
  LPoint2: TPoint;
  LRect1: TRect;
  LRect2: TRect;
  LSize: TSize;
  
begin
  WriteLn('=== Testing Types ===');
  WriteLn();
  
  // Test Point
  LPoint1 := Point(10, 20);
  WriteLn('Point(10, 20): X=', LPoint1.X, ', Y=', LPoint1.Y);
  WriteLn();
  
  // Test Rect
  LRect1 := Rect(0, 0, 100, 50);
  WriteLn('Rect(0, 0, 100, 50):');
  WriteLn('  Width: ', RectWidth(LRect1));
  WriteLn('  Height: ', RectHeight(LRect1));
  WriteLn('  IsEmpty: ', IsRectEmpty(LRect1));
  WriteLn();
  
  // Test Bounds
  LRect2 := Bounds(10, 10, 80, 40);
  WriteLn('Bounds(10, 10, 80, 40):');
  WriteLn('  Left=', LRect2.Left, ', Top=', LRect2.Top);
  WriteLn('  Right=', LRect2.Right, ', Bottom=', LRect2.Bottom);
  WriteLn();
  
  // Test PtInRect
  LPoint2 := Point(50, 25);
  WriteLn('PtInRect(Rect(0,0,100,50), Point(50,25)): ', PtInRect(LRect1, LPoint2));
  LPoint2 := Point(150, 25);
  WriteLn('PtInRect(Rect(0,0,100,50), Point(150,25)): ', PtInRect(LRect1, LPoint2));
  WriteLn();
  
  // Test OffsetRect
  LRect2 := Rect(10, 10, 50, 50);
  WriteLn('Before OffsetRect(20, 30): Left=', LRect2.Left, ', Top=', LRect2.Top);
  OffsetRect(LRect2, 20, 30);
  WriteLn('After OffsetRect(20, 30): Left=', LRect2.Left, ', Top=', LRect2.Top);
  WriteLn();
  
  // Test Size
  LSize := Size(640, 480);
  WriteLn('Size(640, 480): CX=', LSize.CX, ', CY=', LSize.CY);
  WriteLn();
end;

procedure TestSysUtils();
var
  LPath: String;
  LFileName: String;
  LResult: String;
  
begin
  WriteLn('=== Testing SysUtils ===');
  WriteLn();
  
  LPath := 'C:\Users\Documents\MyFile.txt';
  
  // Test path extraction functions
  WriteLn('Full path: ', LPath);
  WriteLn('ExtractFilePath: ', ExtractFilePath(LPath));
  WriteLn('ExtractFileDir: ', ExtractFileDir(LPath));
  WriteLn('ExtractFileName: ', ExtractFileName(LPath));
  WriteLn('ExtractFileExt: ', ExtractFileExt(LPath));
  WriteLn('ExtractFileDrive: ', ExtractFileDrive(LPath));
  WriteLn();
  
  // Test ChangeFileExt
  LFileName := 'document.txt';
  LResult := ChangeFileExt(LFileName, '.doc');
  WriteLn('ChangeFileExt("', LFileName, '", ".doc"): ', LResult);
  WriteLn();
  
  // Test path delimiter functions
  LPath := 'C:\MyFolder';
  LResult := IncludeTrailingPathDelimiter(LPath);
  WriteLn('IncludeTrailingPathDelimiter("', LPath, '"): ', LResult);
  
  LPath := 'C:\MyFolder\\';
  LResult := ExcludeTrailingPathDelimiter(LPath);
  WriteLn('ExcludeTrailingPathDelimiter("', LPath, '"): ', LResult);
  WriteLn();
end;

begin
  TestDateUtils();
  WriteLn();
  
  TestStrUtils();
  WriteLn();
  
  TestTypes();
  WriteLn();
  
  TestSysUtils();
end.
