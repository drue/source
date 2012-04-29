# Source Cookbook

This Chef cookbook provides a resource for building software from source.

# Resources / Providers

## `source_build`

Build/Install source code.  By default, `source_build` works with GNU autoconf style builds (`./configure;make;make install`) but it can be configured to build almost any software package.

### Actions
`source_build` has several actions that it executes the following sequence: `unpack`, `[patch]`, `configure`, `build`, and `install`.  Each action executes the actions that precede it unless you supply the `:skip` attribute.  The default action is `install`.  i.e. if you want to unpack, configure, and build but not install you would specify `build` for the `:action` attribute.  The `patch` action is only executed if you supply the `:patches` attribute and by default happens after `unpack` and before `configure`.

The `name` attribute is used as the `cwd` for each action, except `:unpack`.  `:unpack` happens in the basename of the `name` attribute unless you set `unpack_in`.

* `:unpack` unpack the archive specified by the `:archive` attribute.  The `cwd` of the unpack action is the basename of the `:name` attribute of the resource unless the `unpack_in` attribute is set.

* `:patch` apply the patches listed in the `patches` attribute.  By default this happens after `:unpack` but you can change that with the `patch_after` attribute.

* `:configure` configures the software after unpacking and optionally patching.

* `:build` builds the software after unpacking, patching, and configuring.

* `:install` installs the software after unpacking, patching, configuring, and building.

### Attribute Parameters

* `archive` <b>required</b> path to the archive to unpack.  `source_build` knows how to unpack archives with `.zip`, `.Z`, `.gz`, `.bz`, and `.bz2` extensions.

* `configure` command to configure the software.  Defaults to `./configure`

* `configure_extras` extra stuff to put after the `configure` command, such as `--prefix=/foo/bar`.  Default is an empty string.

* `build` command to build the software.  Defaults to `make`

* `build_extras` extra stuff to put after the `build` command, such as `-f MyMakefile`.  Default is an empty string.

* `install` command to install the software.  Defaults to `make install`.

* `install_extras` extra stuff to put after the `install` command.  Default is an empty string.

* `environment` hash of environment variables to set for the build actions.

* `unpack_in` use this path as the `cwd` of the unpack command.  By default, `source_build` will build in the `basename` of the `name` attribute.  Some software packages are not configured/build/installed from the top level directory inside the archive so the `basename` of the `name` attribute is not a valid path prior to unpacking the archive.  In that case you must set this attribute.

* `patches` a list of paths to patches to apply.

* `patch_extras` extra stuff to put after the patch command, such as `-p1`.  Defaults to `-N`.

* `patch_in` a path to use as the `cwd` of the `patch` command if you don't want it to happen in the path specified by the `name` attribute.

* `patch_after` By default, patching is the next action after `:unpack` (if `patches` is set.)  Set this variable to `configure` or `build` if you want patching to happen after those actions.

* `skip` A list of any actions you want to skip.  


### Providers

Currently there is only one configurable provider, `build`, which should suffice for most situations.

### Examples

    source_build "/tmp/foo-3.2.1" do
        archive "/tmp/foo-3.2.1.tar.gz"
    end

    source_build "/home/vagrant/bar-2.2.2/src" do
        archive "/tmp/bar-2.2.2.tar.gz"
        unpack_in "/home/vagrant"
        patches ["/tmp/my_patch.diff"]
        patch_extras "-p1 -N"
    end
