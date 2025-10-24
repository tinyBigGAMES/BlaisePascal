{===============================================================================
  Blaise Pascal™ - Think in Pascal. Compile to C++

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://github.com/tinyBigGAMES/BlaisePascal

  See LICENSE for license information
===============================================================================}

unit Blaise.CodeGen.Setup;

{$I Blaise.Defines.inc}

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  DelphiAST.Consts;

procedure SetupRuntimeFunctions(const ADictionary: TDictionary<string, Boolean>);
procedure SetupTypeMappings(const ADictionary: TDictionary<string, string>);
procedure SetupOperatorMappings(const ADictionary: TDictionary<TSyntaxNodeType, string>);

implementation

procedure SetupRuntimeFunctions(const ADictionary: TDictionary<string, Boolean>);
begin
  // I/O functions
  ADictionary.TryAdd('WriteLn', True);
  ADictionary.TryAdd('Write', True);
  ADictionary.TryAdd('ReadLn', True);
  ADictionary.TryAdd('Read', True);
  
  // String conversion functions
  ADictionary.TryAdd('IntToStr', True);
  ADictionary.TryAdd('IntToHex', True);
  ADictionary.TryAdd('HexToInt', True);
  ADictionary.TryAdd('StrToInt', True);
  ADictionary.TryAdd('StrToIntDef', True);
  ADictionary.TryAdd('FloatToStr', True);
  ADictionary.TryAdd('StrToFloat', True);
  ADictionary.TryAdd('Val', True);
  ADictionary.TryAdd('Str', True);
  
  // String manipulation functions
  ADictionary.TryAdd('Trim', True);
  ADictionary.TryAdd('TrimLeft', True);
  ADictionary.TryAdd('TrimRight', True);
  ADictionary.TryAdd('UpperCase', True);
  ADictionary.TryAdd('LowerCase', True);
  ADictionary.TryAdd('Pos', True);
  ADictionary.TryAdd('Insert', True);
  ADictionary.TryAdd('Delete', True);
  ADictionary.TryAdd('StringOfChar', True);
  ADictionary.TryAdd('UniqueString', True);
  ADictionary.TryAdd('UpCase', True);
  ADictionary.TryAdd('LowCase', True);
  ADictionary.TryAdd('StringReplace', True);
  ADictionary.TryAdd('CompareStr', True);
  ADictionary.TryAdd('SameText', True);
  ADictionary.TryAdd('QuotedStr', True);
  
  // Array/string functions
  ADictionary.TryAdd('SetLength', True);
  ADictionary.TryAdd('Copy', True);
  ADictionary.TryAdd('Length', True);
  ADictionary.TryAdd('High', True);
  ADictionary.TryAdd('Low', True);
  
  // Set functions
  ADictionary.TryAdd('Include', True);
  ADictionary.TryAdd('Exclude', True);
  
  // File I/O functions
  ADictionary.TryAdd('AssignFile', True);
  ADictionary.TryAdd('Rewrite', True);
  ADictionary.TryAdd('Reset', True);
  ADictionary.TryAdd('BlockWrite', True);
  ADictionary.TryAdd('BlockRead', True);
  ADictionary.TryAdd('CloseFile', True);
  ADictionary.TryAdd('FileSize', True);
  ADictionary.TryAdd('FilePos', True);
  ADictionary.TryAdd('Seek', True);
  ADictionary.TryAdd('Eof', True);
  ADictionary.TryAdd('Eoln', True);
  ADictionary.TryAdd('DeleteFile', True);
  ADictionary.TryAdd('RemoveFile', True);
  ADictionary.TryAdd('RenameFile', True);
  ADictionary.TryAdd('FileExists', True);
  ADictionary.TryAdd('Append', True);
  ADictionary.TryAdd('BoolToStr', True);
  ADictionary.TryAdd('SeekEof', True);
  ADictionary.TryAdd('SeekEoln', True);
  ADictionary.TryAdd('Truncate', True);
  ADictionary.TryAdd('Flush', True);
  ADictionary.TryAdd('IOResult', True);
  
  // Directory operations
  ADictionary.TryAdd('DirectoryExists', True);
  ADictionary.TryAdd('CreateDir', True);
  ADictionary.TryAdd('RemoveDir', True);
  ADictionary.TryAdd('GetCurrentDir', True);
  ADictionary.TryAdd('SetCurrentDir', True);
  
  // Increment/decrement operations
  ADictionary.TryAdd('Inc', True);
  ADictionary.TryAdd('Dec', True);
  
  // Command line functions
  ADictionary.TryAdd('ParamCount', True);
  ADictionary.TryAdd('ParamStr', True);
  
  // Memory functions
  ADictionary.TryAdd('FillChar', True);
  ADictionary.TryAdd('Move', True);
  ADictionary.TryAdd('SizeOf', True);
  ADictionary.TryAdd('GetMem', True);
  ADictionary.TryAdd('FreeMem', True);
  ADictionary.TryAdd('ReallocMem', True);
  ADictionary.TryAdd('AllocMem', True);
  ADictionary.TryAdd('FillByte', True);
  ADictionary.TryAdd('FillWord', True);
  ADictionary.TryAdd('FillDWord', True);
  ADictionary.TryAdd('New', True);
  ADictionary.TryAdd('Dispose', True);

  // Exception functions
  ADictionary.TryAdd('RaiseException', True);
  ADictionary.TryAdd('GetExceptionMessage', True);

  ADictionary.TryAdd('Format', True);

  // Math functions
  ADictionary.TryAdd('Abs', True);
  ADictionary.TryAdd('Sqr', True);
  ADictionary.TryAdd('Sqrt', True);
  ADictionary.TryAdd('Sin', True);
  ADictionary.TryAdd('Cos', True);
  ADictionary.TryAdd('Tan', True);
  ADictionary.TryAdd('ArcSin', True);
  ADictionary.TryAdd('ArcCos', True);
  ADictionary.TryAdd('ArcTan', True);
  ADictionary.TryAdd('Ln', True);
  ADictionary.TryAdd('Exp', True);
  ADictionary.TryAdd('Trunc', True);
  ADictionary.TryAdd('Round', True);
  ADictionary.TryAdd('Int', True);
  ADictionary.TryAdd('Frac', True);
  ADictionary.TryAdd('Ceil', True);
  ADictionary.TryAdd('Floor', True);
  ADictionary.TryAdd('Power', True);
  ADictionary.TryAdd('Pi', True);
  ADictionary.TryAdd('ArcTan2', True);
  ADictionary.TryAdd('Sinh', True);
  ADictionary.TryAdd('Cosh', True);
  ADictionary.TryAdd('Tanh', True);
  ADictionary.TryAdd('ArcSinh', True);
  ADictionary.TryAdd('ArcCosh', True);
  ADictionary.TryAdd('ArcTanh', True);
  ADictionary.TryAdd('Log10', True);
  ADictionary.TryAdd('Log2', True);
  ADictionary.TryAdd('LogN', True);
  ADictionary.TryAdd('Randomize', True);
  ADictionary.TryAdd('Random', True);
  ADictionary.TryAdd('Min', True);
  ADictionary.TryAdd('Max', True);
  ADictionary.TryAdd('Sign', True);

  // Ordinal functions
  ADictionary.TryAdd('Ord', True);
  ADictionary.TryAdd('Chr', True);
  ADictionary.TryAdd('Succ', True);
  ADictionary.TryAdd('Pred', True);
  ADictionary.TryAdd('Odd', True);
  ADictionary.TryAdd('Swap', True);
  
  // Pointer functions
  ADictionary.TryAdd('Assigned', True);
  
  // Program control
  ADictionary.TryAdd('Halt', True);
  ADictionary.TryAdd('Abort', True);
  ADictionary.TryAdd('RunError', True);
end;

procedure SetupTypeMappings(const ADictionary: TDictionary<string, string>);
begin
  ADictionary.Add('Integer', 'bp::Integer');
  ADictionary.Add('Boolean', 'bp::Boolean');
  ADictionary.Add('String', 'bp::String');
  ADictionary.Add('Single', 'bp::Single');
  ADictionary.Add('Double', 'bp::Double');
  ADictionary.Add('Extended', 'bp::Extended');
  ADictionary.Add('Char', 'bp::Char');
  ADictionary.Add('Byte', 'bp::Byte');
  ADictionary.Add('Word', 'bp::Word');
  ADictionary.Add('Cardinal', 'bp::Cardinal');
  ADictionary.Add('Int64', 'bp::Int64');
  ADictionary.Add('UInt64', 'bp::UInt64');
  ADictionary.Add('Pointer', 'bp::Pointer');
  ADictionary.Add('File', 'bp::File');
  ADictionary.Add('TextFile', 'bp::TextFile');
  ADictionary.Add('Text', 'bp::TextFile');
end;

procedure SetupOperatorMappings(const ADictionary: TDictionary<TSyntaxNodeType, string>);
begin
  ADictionary.Add(ntAdd, '+');
  ADictionary.Add(ntSub, '-');
  ADictionary.Add(ntMul, '*');
  ADictionary.Add(ntFDiv, '/');
  ADictionary.Add(ntDiv, '/');
  ADictionary.Add(ntMod, '%');
  ADictionary.Add(ntShl, '<<');
  ADictionary.Add(ntShr, '>>');
  ADictionary.Add(ntAnd, 'AND_OP');  // Context-dependent
  ADictionary.Add(ntOr, 'OR_OP');    // Context-dependent
  ADictionary.Add(ntXor, '^');
  ADictionary.Add(ntNot, 'NOT_OP');  // Context-dependent
  ADictionary.Add(ntUnaryMinus, '-');
  ADictionary.Add(ntAddr, '&');
  ADictionary.Add(ntDeref, '*');
  ADictionary.Add(ntEqual, '==');
  ADictionary.Add(ntNotEqual, '!=');
  ADictionary.Add(ntLower, '<');
  ADictionary.Add(ntGreater, '>');
  ADictionary.Add(ntLowerEqual, '<=');
  ADictionary.Add(ntGreaterEqual, '>=');
end;

end.
