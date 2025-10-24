{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

{$INCLUDE_FILE 'time.h'}

unit DateUtils;

interface

type
  TDateTime = Double;

const
  UnixDateDelta = 25569;
  
  HoursPerDay = 24;
  MinsPerHour = 60;
  SecsPerMin = 60;
  MSecsPerSec = 1000;
  MinsPerDay = HoursPerDay * MinsPerHour;
  SecsPerDay = MinsPerDay * SecsPerMin;
  MSecsPerDay = SecsPerDay * MSecsPerSec;
  
  DateDelta = 693594;
  
  DaysPerWeek = 7;
  WeeksPerYear = 52;
  MonthsPerYear = 12;
  
  OneSecond = 1.0 / SecsPerDay;
  OneMillisecond = 1.0 / MSecsPerDay;
  OneMinute = 1.0 / MinsPerDay;
  OneHour = 1.0 / HoursPerDay;

function  Now(): TDateTime;
function  Date(): TDateTime;
function  Time(): TDateTime;
function  EncodeDate(const AYear: Integer; const AMonth: Integer; const ADay: Integer): TDateTime;
function  EncodeTime(const AHour: Integer; const AMinute: Integer; const ASecond: Integer; const AMilliSecond: Integer): TDateTime;
function  EncodeDateTime(const AYear: Integer; const AMonth: Integer; const ADay: Integer; const AHour: Integer; const AMinute: Integer; const ASecond: Integer; const AMilliSecond: Integer): TDateTime;
procedure DecodeDate(const ADateTime: TDateTime; var AYear: Integer; var AMonth: Integer; var ADay: Integer);
procedure DecodeTime(const ADateTime: TDateTime; var AHour: Integer; var AMinute: Integer; var ASecond: Integer; var AMilliSecond: Integer);
procedure DecodeDateTime(const ADateTime: TDateTime; var AYear: Integer; var AMonth: Integer; var ADay: Integer; var AHour: Integer; var AMinute: Integer; var ASecond: Integer; var AMilliSecond: Integer);
function  IsLeapYear(const AYear: Integer): Boolean;
function  DaysInMonth(const AYear: Integer; const AMonth: Integer): Integer;
function  DaysInYear(const AYear: Integer): Integer;
function  DateOf(const ADateTime: TDateTime): TDateTime;
function  TimeOf(const ADateTime: TDateTime): TDateTime;
function  YearOf(const ADateTime: TDateTime): Integer;
function  MonthOf(const ADateTime: TDateTime): Integer;
function  DayOf(const ADateTime: TDateTime): Integer;
function  HourOf(const ADateTime: TDateTime): Integer;
function  MinuteOf(const ADateTime: TDateTime): Integer;
function  SecondOf(const ADateTime: TDateTime): Integer;
function  MilliSecondOf(const ADateTime: TDateTime): Integer;
function  IncYear(const ADateTime: TDateTime; const ANumberOfYears: Integer): TDateTime;
function  IncMonth(const ADateTime: TDateTime; const ANumberOfMonths: Integer): TDateTime;
function  IncWeek(const ADateTime: TDateTime; const ANumberOfWeeks: Integer): TDateTime;
function  IncDay(const ADateTime: TDateTime; const ANumberOfDays: Integer): TDateTime;
function  IncHour(const ADateTime: TDateTime; const ANumberOfHours: Int64): TDateTime;
function  IncMinute(const ADateTime: TDateTime; const ANumberOfMinutes: Int64): TDateTime;
function  IncSecond(const ADateTime: TDateTime; const ANumberOfSeconds: Int64): TDateTime;
function  IncMilliSecond(const ADateTime: TDateTime; const ANumberOfMilliSeconds: Int64): TDateTime;
function  DaysBetween(const ADateTime1: TDateTime; const ADateTime2: TDateTime): Integer;
function  HoursBetween(const ADateTime1: TDateTime; const ADateTime2: TDateTime): Int64;
function  MinutesBetween(const ADateTime1: TDateTime; const ADateTime2: TDateTime): Int64;
function  SecondsBetween(const ADateTime1: TDateTime; const ADateTime2: TDateTime): Int64;
function  MilliSecondsBetween(const ADateTime1: TDateTime; const ADateTime2: TDateTime): Int64;
function  CompareDate(const ADateTime1: TDateTime; const ADateTime2: TDateTime): Integer;
function  CompareDateTime(const ADateTime1: TDateTime; const ADateTime2: TDateTime): Integer;
function  CompareTime(const ADateTime1: TDateTime; const ADateTime2: TDateTime): Integer;
function  SameDate(const ADateTime1: TDateTime; const ADateTime2: TDateTime): Boolean;
function  SameDateTime(const ADateTime1: TDateTime; const ADateTime2: TDateTime): Boolean;
function  SameTime(const ADateTime1: TDateTime; const ADateTime2: TDateTime): Boolean;
function  DayOfWeek(const ADateTime: TDateTime): Integer;
function  FormatDateTime(const AFormat: String; const ADateTime: TDateTime): String;

implementation

function time(ATimer: Pointer): Int64; external;
function localtime(const ATimer: Pointer): Pointer; external;

const
  DaysInMonthArray: array[1..12] of Integer = (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);

function UnixTimeToDateTime(const AUnixTime: Int64): TDateTime;
begin
  Result := (AUnixTime / 86400.0) + UnixDateDelta;
end;

function Now(): TDateTime;
var
  LTime: Int64;
begin
  LTime := time(nil);
  Result := UnixTimeToDateTime(LTime);
end;

function Date(): TDateTime;
var
  LTime: Int64;
  LDaysSince1970: Int64;
begin
  LTime := time(nil);
  LDaysSince1970 := LTime div 86400;
  Result := LDaysSince1970 + UnixDateDelta;
end;

function Time(): TDateTime;
var
  LTime: Int64;
  LSecondsInDay: Int64;
begin
  LTime := time(nil);
  LSecondsInDay := LTime mod 86400;
  Result := LSecondsInDay / 86400.0;
end;

function IsLeapYear(const AYear: Integer): Boolean;
begin
  Result := ((AYear mod 4) = 0) and (((AYear mod 100) <> 0) or ((AYear mod 400) = 0));
end;

function DaysInMonth(const AYear: Integer; const AMonth: Integer): Integer;
begin
  if (AMonth < 1) or (AMonth > 12) then
  begin
    Result := 0;
  end
  else if (AMonth = 2) and IsLeapYear(AYear) then
  begin
    Result := 29;
  end
  else
  begin
    Result := DaysInMonthArray[AMonth];
  end;
end;

function DaysInYear(const AYear: Integer): Integer;
begin
  if IsLeapYear(AYear) then
  begin
    Result := 366;
  end
  else
  begin
    Result := 365;
  end;
end;

function EncodeDate(const AYear: Integer; const AMonth: Integer; const ADay: Integer): TDateTime;
var
  LYear: Integer;
  LMonth: Integer;
  LDayCount: Integer;
begin
  LDayCount := 0;
  
  for LYear := 1 to AYear - 1 do
  begin
    LDayCount := LDayCount + DaysInYear(LYear);
  end;
  
  for LMonth := 1 to AMonth - 1 do
  begin
    LDayCount := LDayCount + DaysInMonth(AYear, LMonth);
  end;
  
  LDayCount := LDayCount + ADay - 1;
  
  Result := LDayCount - DateDelta;
end;

function EncodeTime(const AHour: Integer; const AMinute: Integer; const ASecond: Integer; const AMilliSecond: Integer): TDateTime;
begin
  Result := (AHour * 3600000 + AMinute * 60000 + ASecond * 1000 + AMilliSecond) / MSecsPerDay;
end;

function EncodeDateTime(const AYear: Integer; const AMonth: Integer; const ADay: Integer; const AHour: Integer; const AMinute: Integer; const ASecond: Integer; const AMilliSecond: Integer): TDateTime;
begin
  Result := EncodeDate(AYear, AMonth, ADay) + EncodeTime(AHour, AMinute, ASecond, AMilliSecond);
end;

procedure DecodeDate(const ADateTime: TDateTime; var AYear: Integer; var AMonth: Integer; var ADay: Integer);
var
  LDayCount: Integer;
  LYear: Integer;
  LMonth: Integer;
  LDaysInYear: Integer;
  LDaysInMonth: Integer;
  LYearEstimate: Integer;
  LLeapYears: Integer;
begin
  // TDateTime day 0 = December 30, 1899
  // Convert to days since January 1, 0001
  LDayCount := Trunc(ADateTime) + DateDelta;
  
  // Quick estimate: Start from a reasonable year (most dates will be 1900+)
  // Average year is 365.25 days
  LYearEstimate := LDayCount div 365;
  if LYearEstimate < 1 then
  begin
    LYearEstimate := 1;
  end;
  
  // Calculate actual days up to estimated year
  LYear := 1;
  LDaysInYear := 0;
  
  // Calculate days from year 1 to year before estimate
  if LYearEstimate > 1 then
  begin
    // Count leap years from 1 to YearEstimate-1
    LLeapYears := ((LYearEstimate - 1) div 4) - ((LYearEstimate - 1) div 100) + ((LYearEstimate - 1) div 400);
    LDaysInYear := (LYearEstimate - 1) * 365 + LLeapYears;
    
    if LDaysInYear < LDayCount then
    begin
      LYear := LYearEstimate;
      LDayCount := LDayCount - LDaysInYear;
    end;
  end;
  
  // Now iterate from estimated year forward
  while True do
  begin
    LDaysInYear := DaysInYear(LYear);
    if LDayCount <= LDaysInYear then
    begin
      Break;
    end;
    LDayCount := LDayCount - LDaysInYear;
    LYear := LYear + 1;
  end;
  
  // Now find the month
  LMonth := 1;
  while LMonth <= 12 do
  begin
    LDaysInMonth := DaysInMonth(LYear, LMonth);
    if LDayCount <= LDaysInMonth then
    begin
      Break;
    end;
    LDayCount := LDayCount - LDaysInMonth;
    LMonth := LMonth + 1;
  end;
  
  AYear := LYear;
  AMonth := LMonth;
  ADay := LDayCount;
end;

procedure DecodeTime(const ADateTime: TDateTime; var AHour: Integer; var AMinute: Integer; var ASecond: Integer; var AMilliSecond: Integer);
var
  LTime: Double;
  LMSecs: Integer;
begin
  LTime := Frac(ADateTime);
  LMSecs := Round(LTime * MSecsPerDay);
  
  AHour := LMSecs div 3600000;
  LMSecs := LMSecs mod 3600000;
  
  AMinute := LMSecs div 60000;
  LMSecs := LMSecs mod 60000;
  
  ASecond := LMSecs div 1000;
  AMilliSecond := LMSecs mod 1000;
end;

procedure DecodeDateTime(const ADateTime: TDateTime; var AYear: Integer; var AMonth: Integer; var ADay: Integer; var AHour: Integer; var AMinute: Integer; var ASecond: Integer; var AMilliSecond: Integer);
begin
  DecodeDate(ADateTime, AYear, AMonth, ADay);
  DecodeTime(ADateTime, AHour, AMinute, ASecond, AMilliSecond);
end;

function DateOf(const ADateTime: TDateTime): TDateTime;
begin
  Result := Trunc(ADateTime);
end;

function TimeOf(const ADateTime: TDateTime): TDateTime;
begin
  Result := Frac(ADateTime);
end;

function YearOf(const ADateTime: TDateTime): Integer;
var
  LYear: Integer;
  LMonth: Integer;
  LDay: Integer;
begin
  DecodeDate(ADateTime, LYear, LMonth, LDay);
  Result := LYear;
end;

function MonthOf(const ADateTime: TDateTime): Integer;
var
  LYear: Integer;
  LMonth: Integer;
  LDay: Integer;
begin
  DecodeDate(ADateTime, LYear, LMonth, LDay);
  Result := LMonth;
end;

function DayOf(const ADateTime: TDateTime): Integer;
var
  LYear: Integer;
  LMonth: Integer;
  LDay: Integer;
begin
  DecodeDate(ADateTime, LYear, LMonth, LDay);
  Result := LDay;
end;

function HourOf(const ADateTime: TDateTime): Integer;
var
  LHour: Integer;
  LMinute: Integer;
  LSecond: Integer;
  LMilliSecond: Integer;
begin
  DecodeTime(ADateTime, LHour, LMinute, LSecond, LMilliSecond);
  Result := LHour;
end;

function MinuteOf(const ADateTime: TDateTime): Integer;
var
  LHour: Integer;
  LMinute: Integer;
  LSecond: Integer;
  LMilliSecond: Integer;
begin
  DecodeTime(ADateTime, LHour, LMinute, LSecond, LMilliSecond);
  Result := LMinute;
end;

function SecondOf(const ADateTime: TDateTime): Integer;
var
  LHour: Integer;
  LMinute: Integer;
  LSecond: Integer;
  LMilliSecond: Integer;
begin
  DecodeTime(ADateTime, LHour, LMinute, LSecond, LMilliSecond);
  Result := LSecond;
end;

function MilliSecondOf(const ADateTime: TDateTime): Integer;
var
  LHour: Integer;
  LMinute: Integer;
  LSecond: Integer;
  LMilliSecond: Integer;
begin
  DecodeTime(ADateTime, LHour, LMinute, LSecond, LMilliSecond);
  Result := LMilliSecond;
end;

function IncYear(const ADateTime: TDateTime; const ANumberOfYears: Integer): TDateTime;
var
  LYear: Integer;
  LMonth: Integer;
  LDay: Integer;
  LHour: Integer;
  LMinute: Integer;
  LSecond: Integer;
  LMilliSecond: Integer;
begin
  DecodeDateTime(ADateTime, LYear, LMonth, LDay, LHour, LMinute, LSecond, LMilliSecond);
  LYear := LYear + ANumberOfYears;
  
  if LDay > DaysInMonth(LYear, LMonth) then
  begin
    LDay := DaysInMonth(LYear, LMonth);
  end;
  
  Result := EncodeDateTime(LYear, LMonth, LDay, LHour, LMinute, LSecond, LMilliSecond);
end;

function IncMonth(const ADateTime: TDateTime; const ANumberOfMonths: Integer): TDateTime;
var
  LYear: Integer;
  LMonth: Integer;
  LDay: Integer;
  LHour: Integer;
  LMinute: Integer;
  LSecond: Integer;
  LMilliSecond: Integer;
  LTotalMonths: Integer;
begin
  DecodeDateTime(ADateTime, LYear, LMonth, LDay, LHour, LMinute, LSecond, LMilliSecond);
  
  LTotalMonths := (LYear - 1) * 12 + LMonth + ANumberOfMonths;
  LYear := ((LTotalMonths - 1) div 12) + 1;
  LMonth := ((LTotalMonths - 1) mod 12) + 1;
  
  if LDay > DaysInMonth(LYear, LMonth) then
  begin
    LDay := DaysInMonth(LYear, LMonth);
  end;
  
  Result := EncodeDateTime(LYear, LMonth, LDay, LHour, LMinute, LSecond, LMilliSecond);
end;

function IncWeek(const ADateTime: TDateTime; const ANumberOfWeeks: Integer): TDateTime;
begin
  Result := ADateTime + (ANumberOfWeeks * 7);
end;

function IncDay(const ADateTime: TDateTime; const ANumberOfDays: Integer): TDateTime;
begin
  Result := ADateTime + ANumberOfDays;
end;

function IncHour(const ADateTime: TDateTime; const ANumberOfHours: Int64): TDateTime;
begin
  Result := ADateTime + (ANumberOfHours / HoursPerDay);
end;

function IncMinute(const ADateTime: TDateTime; const ANumberOfMinutes: Int64): TDateTime;
begin
  Result := ADateTime + (ANumberOfMinutes / MinsPerDay);
end;

function IncSecond(const ADateTime: TDateTime; const ANumberOfSeconds: Int64): TDateTime;
begin
  Result := ADateTime + (ANumberOfSeconds / SecsPerDay);
end;

function IncMilliSecond(const ADateTime: TDateTime; const ANumberOfMilliSeconds: Int64): TDateTime;
begin
  Result := ADateTime + (ANumberOfMilliSeconds / MSecsPerDay);
end;

function DaysBetween(const ADateTime1: TDateTime; const ADateTime2: TDateTime): Integer;
begin
  Result := Abs(Trunc(ADateTime2) - Trunc(ADateTime1));
end;

function HoursBetween(const ADateTime1: TDateTime; const ADateTime2: TDateTime): Int64;
begin
  Result := Round(Abs(ADateTime2 - ADateTime1) * HoursPerDay);
end;

function MinutesBetween(const ADateTime1: TDateTime; const ADateTime2: TDateTime): Int64;
begin
  Result := Round(Abs(ADateTime2 - ADateTime1) * MinsPerDay);
end;

function SecondsBetween(const ADateTime1: TDateTime; const ADateTime2: TDateTime): Int64;
begin
  Result := Round(Abs(ADateTime2 - ADateTime1) * SecsPerDay);
end;

function MilliSecondsBetween(const ADateTime1: TDateTime; const ADateTime2: TDateTime): Int64;
begin
  Result := Round(Abs(ADateTime2 - ADateTime1) * MSecsPerDay);
end;

function CompareDate(const ADateTime1: TDateTime; const ADateTime2: TDateTime): Integer;
var
  LDate1: TDateTime;
  LDate2: TDateTime;
begin
  LDate1 := DateOf(ADateTime1);
  LDate2 := DateOf(ADateTime2);
  
  if LDate1 < LDate2 then
  begin
    Result := -1;
  end
  else if LDate1 > LDate2 then
  begin
    Result := 1;
  end
  else
  begin
    Result := 0;
  end;
end;

function CompareDateTime(const ADateTime1: TDateTime; const ADateTime2: TDateTime): Integer;
begin
  if ADateTime1 < ADateTime2 then
  begin
    Result := -1;
  end
  else if ADateTime1 > ADateTime2 then
  begin
    Result := 1;
  end
  else
  begin
    Result := 0;
  end;
end;

function CompareTime(const ADateTime1: TDateTime; const ADateTime2: TDateTime): Integer;
var
  LTime1: TDateTime;
  LTime2: TDateTime;
begin
  LTime1 := TimeOf(ADateTime1);
  LTime2 := TimeOf(ADateTime2);
  
  if LTime1 < LTime2 then
  begin
    Result := -1;
  end
  else if LTime1 > LTime2 then
  begin
    Result := 1;
  end
  else
  begin
    Result := 0;
  end;
end;

function SameDate(const ADateTime1: TDateTime; const ADateTime2: TDateTime): Boolean;
begin
  Result := CompareDate(ADateTime1, ADateTime2) = 0;
end;

function SameDateTime(const ADateTime1: TDateTime; const ADateTime2: TDateTime): Boolean;
begin
  Result := CompareDateTime(ADateTime1, ADateTime2) = 0;
end;

function SameTime(const ADateTime1: TDateTime; const ADateTime2: TDateTime): Boolean;
begin
  Result := CompareTime(ADateTime1, ADateTime2) = 0;
end;

function DayOfWeek(const ADateTime: TDateTime): Integer;
begin
  // Delphi's TDateTime day 0 (December 30, 1899) was a Saturday
  // So we add 1 to make Sunday = 1, Monday = 2, etc.
  Result := ((Trunc(ADateTime) - 1) mod 7) + 1;
  if Result < 1 then
  begin
    Result := Result + 7;
  end;
end;

function FormatDateTime(const AFormat: String; const ADateTime: TDateTime): String;
var
  LYear: Integer;
  LMonth: Integer;
  LDay: Integer;
  LHour: Integer;
  LMinute: Integer;
  LSecond: Integer;
  LMilliSecond: Integer;
  LIndex: Integer;
  LFormatLen: Integer;
  LCharStr: String;
  LCount: Integer;
  LValue: String;
begin
  DecodeDateTime(ADateTime, LYear, LMonth, LDay, LHour, LMinute, LSecond, LMilliSecond);
  
  Result := '';
  LIndex := 1;
  LFormatLen := Length(AFormat);
  
  while LIndex <= LFormatLen do
  begin
    LCharStr := Copy(AFormat, LIndex, 1);
    LCount := 1;
    
    // Count consecutive identical characters
    while (LIndex + LCount <= LFormatLen) and (Copy(AFormat, LIndex + LCount, 1) = LCharStr) do
    begin
      LCount := LCount + 1;
    end;
    
    // Process based on the format character and count
    if (LCharStr = 'd') or (LCharStr = 'D') then
    begin
      if LCount = 1 then
      begin
        LValue := IntToStr(LDay);
      end
      else if LCount = 2 then
      begin
        LValue := Format('%.2d', LDay);
      end
      else if LCount = 3 then
      begin
        // ddd = abbreviated day name
        case DayOfWeek(ADateTime) of
          1: LValue := 'Sun';
          2: LValue := 'Mon';
          3: LValue := 'Tue';
          4: LValue := 'Wed';
          5: LValue := 'Thu';
          6: LValue := 'Fri';
          7: LValue := 'Sat';
        else
          LValue := '';
        end;
      end
      else
      begin
        // dddd = full day name
        case DayOfWeek(ADateTime) of
          1: LValue := 'Sunday';
          2: LValue := 'Monday';
          3: LValue := 'Tuesday';
          4: LValue := 'Wednesday';
          5: LValue := 'Thursday';
          6: LValue := 'Friday';
          7: LValue := 'Saturday';
        else
          LValue := '';
        end;
      end;
    end
    else if (LCharStr = 'm') or (LCharStr = 'M') then
    begin
      if LCount = 1 then
      begin
        LValue := IntToStr(LMonth);
      end
      else if LCount = 2 then
      begin
        LValue := Format('%.2d', LMonth);
      end
      else if LCount = 3 then
      begin
        // mmm = abbreviated month name
        case LMonth of
          1: LValue := 'Jan';
          2: LValue := 'Feb';
          3: LValue := 'Mar';
          4: LValue := 'Apr';
          5: LValue := 'May';
          6: LValue := 'Jun';
          7: LValue := 'Jul';
          8: LValue := 'Aug';
          9: LValue := 'Sep';
          10: LValue := 'Oct';
          11: LValue := 'Nov';
          12: LValue := 'Dec';
        else
          LValue := '';
        end;
      end
      else
      begin
        // mmmm = full month name
        case LMonth of
          1: LValue := 'January';
          2: LValue := 'February';
          3: LValue := 'March';
          4: LValue := 'April';
          5: LValue := 'May';
          6: LValue := 'June';
          7: LValue := 'July';
          8: LValue := 'August';
          9: LValue := 'September';
          10: LValue := 'October';
          11: LValue := 'November';
          12: LValue := 'December';
        else
          LValue := '';
        end;
      end;
    end
    else if (LCharStr = 'y') or (LCharStr = 'Y') then
    begin
      if LCount = 2 then
      begin
        LValue := Format('%.2d', LYear mod 100);
      end
      else
      begin
        LValue := IntToStr(LYear);
      end;
    end
    else if (LCharStr = 'h') or (LCharStr = 'H') then
    begin
      if LCount = 1 then
      begin
        LValue := IntToStr(LHour);
      end
      else
      begin
        LValue := Format('%.2d', LHour);
      end;
    end
    else if (LCharStr = 'n') or (LCharStr = 'N') then
    begin
      if LCount = 1 then
      begin
        LValue := IntToStr(LMinute);
      end
      else
      begin
        LValue := Format('%.2d', LMinute);
      end;
    end
    else if (LCharStr = 's') or (LCharStr = 'S') then
    begin
      if LCount = 1 then
      begin
        LValue := IntToStr(LSecond);
      end
      else
      begin
        LValue := Format('%.2d', LSecond);
      end;
    end
    else if (LCharStr = 'z') or (LCharStr = 'Z') then
    begin
      LValue := Format('%.3d', LMilliSecond);
    end
    else
    begin
      // Literal character - just use it as-is
      LValue := Copy(AFormat, LIndex, LCount);
    end;
    
    Result := Result + LValue;
    LIndex := LIndex + LCount;
  end;
end;

end.
