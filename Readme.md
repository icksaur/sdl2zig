## Creating a C module in build.zig

Zig's @cImport is deprecated, and it's preferable to use std.Build.Step.TranslateC.  This example shows how to use that and import the named module.