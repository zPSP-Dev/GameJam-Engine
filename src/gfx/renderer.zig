usingnamespace @import("../Zig-PSP/src/psp/include/pspgu.zig");
usingnamespace @import("../Zig-PSP/src/psp/include/pspdisplay.zig");
usingnamespace @import("../Zig-PSP/src/psp/include/pspctrl.zig");
usingnamespace @import("../Zig-PSP/src/psp/include/pspgum.zig");
const vram = @import("../Zig-PSP/src/psp/utils/vram.zig");
usingnamespace @import("../Zig-PSP/src/psp/utils/constants.zig");

var fbp0: ?*c_void = null;
var fbp1: ?*c_void = null;
var zbp0: ?*c_void = null;

var display_list : [0x20000]u32 align(16) = [_]u32{0} ** 0x20000;

pub fn init() void {
    fbp0 = vram.allocVramRelative(SCR_BUF_WIDTH, SCREEN_HEIGHT, GuPixelMode.Psm8888);
    fbp0 = vram.allocVramRelative(SCR_BUF_WIDTH, SCREEN_HEIGHT, GuPixelMode.Psm8888);
    zbp0 = vram.allocVramRelative(SCR_BUF_WIDTH, SCREEN_HEIGHT, GuPixelMode.Psm4444);

    sceGuInit();
    sceGuStart(GuContextType.Direct, @ptrCast(*c_void, &display_list));
    sceGuDrawBuffer(GuPixelMode.Psm8888, fbp0, SCR_BUF_WIDTH);
    sceGuDispBuffer(SCREEN_WIDTH, SCREEN_HEIGHT, fbp1, SCR_BUF_WIDTH);
    sceGuDepthBuffer(zbp0, SCR_BUF_WIDTH);

    sceGuOffset(2048 - SCREEN_WIDTH/2, 2048 - SCREEN_HEIGHT/2);
    sceGuViewport(2048, 2048, SCREEN_WIDTH, SCREEN_HEIGHT);
    
    sceGuDepthRange(65535, 0);
    sceGuScissor(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    sceGuEnable(GuState.ScissorTest);
    
    sceGuDepthFunc(DepthFunc.GreaterOrEqual);
    sceGuEnable(GuState.DepthTest);

    sceGuDisable(GuState.Texture2D);
    sceGuEnable(GuState.ClipPlanes);

    sceGuEnable(GuState.CullFace);
    sceGuFrontFace(FrontFaceDirection.CounterClockwise);

    sceGuEnable(GuState.Blend);
    sceGuBlendFunc(BlendOp.Add, BlendArg.SrcAlpha, BlendArg.OneMinusSrcAlpha, 0, 0);
    sceGuAlphaFunc(AlphaFunc.Greater, 0.0, 0xff);

    sceGuStencilFunc(StencilFunc.Always, 1, 1);
    sceGuStencilOp(StencilOperation.Keep, StencilOperation.Keep, StencilOperation.Replace);

    sceGuTexFilter(TextureFilter.Linear, TextureFilter.Linear);

    sceGuShadeModel(ShadeModel.Smooth);
    sceGuEnable(GuState.Texture2D);
    guFinish();

    displayWaitVblankStart();
    sceGuDisplay(true);

    _ = sceCtrlSetSamplingCycle(0);
    _ = ctrlSetSamplingMode(PspCtrlMode.Analog);

}

pub fn deinit() void {
    sceGuTerm();
}

pub fn recordCommands() void {
    sceGuStart(GuContextType.Direct,  @ptrCast(*c_void, &display_list));
}

var clearColor : u32 = 0xff000000;

pub fn setClearColor(r: u8, g: u8, b: u8, a: u8) void {
    clearColor = rgba(r, g, b, a);
}

pub fn set2D() void{
    sceGumMatrixMode(MatrixMode.Projection);
    sceGumOrtho(0, 480, 272, 0, -16, 15);
    sceGumMatrixMode(MatrixMode.View);
    sceGumLoadIdentity();
    sceGumMatrixMode(MatrixMode.Model);
    sceGumLoadIdentity();
}

pub fn clear() void {
    sceGuClearColor(clearColor);
    sceGuClear(@enumToInt(ClearBitFlags.ColorBuffer) + @enumToInt(ClearBitFlags.DepthBuffer) + @enumToInt(ClearBitFlags.StencilBuffer));
    sceGuClearDepth(0);
}

pub fn submitCommands() void {
    guFinish();
    _ = sceGuSync(GuSyncMode.Finish, GuSyncBehavior.Wait);
    _ = sceGuSwapBuffers();
    displayWaitVblankStart();
}
