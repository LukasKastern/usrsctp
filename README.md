# libjuice

This is [usrsctp](https://github.com/paullouisageneau/usrsctp), packaged for Zig.

## Installation

First, update your `build.zig.zon`:

```
# Initialize a `zig build` project if you haven't already
zig init
zig fetch --save git+https://github.com/lukaskastern/libjuice.git
```

You can then import `usrsctp` in your `build.zig` with:

```zig
const usrsctp_dependency = b.dependency("usrsctp", .{
    .target = target,
    .optimize = optimize,
});
your_exe.linkLibrary(usrsctp_dependency.artifact("usrsctp"));
```

And use the library like this:
```zig
const usrsctp = @cImport({
    @cInclude("usrsctp.h");
});

...
```

### Zig Version
The target zig version is 0.14.0
