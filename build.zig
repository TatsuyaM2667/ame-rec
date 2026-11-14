// ame-shell(https://github.com/TatsuyaM2667/ame-shell)の src/cmd/ame-rec.zig から生成。直すときは ame-shell の方を直す
const std = @import("std");

const protocols = [_][]const u8{ "protocol/ext-foreign-toplevel-list-v1.xml", "protocol/ext-image-capture-source-v1.xml", "protocol/ext-image-copy-capture-v1.xml", };

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    // プロトコルの XML から C のヘッダと glue を作り、1 つのフォルダに集める
    const gen = b.addWriteFiles();
    var proto_c = std.ArrayList(std.Build.LazyPath).init(b.allocator);
    for (protocols) |xml| {
        const base = std.fs.path.stem(xml);
        const hdr = b.addSystemCommand(&.{ "wayland-scanner", "client-header" });
        hdr.addFileArg(b.path(xml));
        _ = gen.addCopyFile(hdr.addOutputFileArg(b.fmt("{s}-client-protocol.h", .{base})), b.fmt("{s}-client-protocol.h", .{base}));
        const code = b.addSystemCommand(&.{ "wayland-scanner", "private-code" });
        code.addFileArg(b.path(xml));
        proto_c.append(code.addOutputFileArg(b.fmt("{s}-protocol.c", .{base}))) catch @panic("oom");
    }
    for ([_]bool{ false, true }) |is_test| {
        const exe = if (is_test)
            b.addTest(.{ .root_source_file = b.path("src/main.zig"), .target = target, .optimize = optimize })
        else
            b.addExecutable(.{ .name = "ame-rec", .root_source_file = b.path("src/main.zig"), .target = target, .optimize = optimize });
        exe.linkLibC();
        exe.addIncludePath(gen.getDirectory());
        for (proto_c.items) |f| exe.addCSourceFile(.{ .file = f, .flags = &.{"-std=c11"} });
    exe.linkSystemLibrary("wayland-client");
        if (is_test) {
            b.step("test", "テスト").dependOn(&b.addRunArtifact(exe).step);
        } else {
            b.installArtifact(exe);
        }
    }
}
