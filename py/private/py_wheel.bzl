"Represent a python wheel file"

load("@bazel_skylib//lib:types.bzl", "types")
load("//py/private:providers.bzl", "PyWheelInfo")

_ATTRS = {
    "src": attr.label(
        allow_files = [".whl"],
    ),
}

def _make_py_wheel_info(ctx, wheel_filegroups):
    if not types.is_list(wheel_filegroups):
        filegroups = [wheel_filegroups]
    else:
        filegroups = wheel_filegroups

    files_depsets = []
    runfiles = []
    for filegroup in filegroups:
        if DefaultInfo in filegroup:
            files_depsets.append(filegroup[DefaultInfo].files)
            files_depsets.append(filegroup[DefaultInfo].default_runfiles.files)
            runfiles.append(filegroup[DefaultInfo].default_runfiles)

        if PyWheelInfo in filegroup:
            files_depsets.append(filegroup[PyWheelInfo].files)
            runfiles.append(filegroup[PyWheelInfo].default_runfiles)

    py_info_runfiles = ctx.runfiles()
    py_info_runfiles = py_info_runfiles.merge_all(runfiles)

    return PyWheelInfo(
        files = depset(transitive = files_depsets),
        default_runfiles = py_info_runfiles,
    )

def _py_wheel_impl(ctx):
    py_wheel_info = _make_py_wheel_info(ctx, ctx.attr.src)
    return [
        py_wheel_info,
    ]

py_wheel_lib = struct(
    implementation = _py_wheel_impl,
    attrs = _ATTRS,
    provides = [PyWheelInfo],
    make_py_wheel_info = _make_py_wheel_info,
)