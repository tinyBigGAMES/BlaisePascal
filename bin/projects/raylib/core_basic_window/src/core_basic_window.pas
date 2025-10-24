{===============================================================================
  NitroPascal - Modern Pascal • C Performance

  Copyright © 2025-present tinyBigGAMES™ LLC
  All Rights Reserved.

  https://nitropascal.org

  See LICENSE for license information
===============================================================

// Optimization
{$OPTIMIZATION "releasesmall"}

{$UNIT_PATH   ".\res\libs\raylib\pas"}

program core_basic_window;

uses
  raylib;

const
  LScreenWidth = 800;
  LScreenHeight = 450;

begin
  InitWindow(LScreenWidth, LScreenHeight, '#Araylib [core] example - basic window');
  SetTargetFPS(60);
  
  while not WindowShouldClose() do
  begin
    BeginDrawing();
      ClearBackground(RAYWHITE);
      DrawText('#ACongrats! You created your first window!', 190, 200, 20, LIGHTGRAY);
    EndDrawing();
  end;
  
  CloseWindow();
end.