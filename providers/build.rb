require 'pathname'

action :unpack do
  unpack
end

action :configure do
  unpack
  step("configure")
end

action :build do
  unpack
  step("configure")
  step("build")
end

action :install do
  unpack
  step("configure")
  step("build")
  step("install")
end

action :clean do
  nil
end

def patch
  if !new_resource.patches.empty? then
    patched = ::File.join(new_resource.name, "_patched")

    new_resource.patches.each do |patch|
      bash "patch #{patch}" do
        cwd new_resource.patch_in || new_resource.name
        code "cat #{patch} | patch #{new_resource.patch_extras}"
        not_if "test -f #{patched}"
      end
    end

    file patched
  end
end

def unpack
  if new_resource.skip.include?("unpack") then
    return
  end
  arcpath = Pathname.new(new_resource.archive)
  unpacked = ::File.join(new_resource.name, "_unpacked")

  # tar operation
  if new_resource.archive.end_with?('gz') then
    if node.platform == "mac_os_x" then op = 'gzcat' else op = 'zcat' end
  elsif new_resource.archive.end_with?('bz') || new_resource.archive.end_with?('bz2') then
    op = 'bzcat'
  elsif new_resource.archive.end_with?('.Z') then
    op = 'zcat'
  end

  bash "unpack #{arcpath.basename}" do
    if new_resource.archive.end_with?('.zip') then
      code "unzip -u #{new_resource.archive}"
    else
      code "#{op} #{new_resource.archive} | tar -xf -"
    end
    cwd new_resource.unpack_in || Pathname.new(new_resource.name).dirname.to_s
    not_if "test -f #{unpacked}"
  end

  if new_resource.patch_after == "unpack" then
    patch
  end

  file unpacked do
    action :create_if_missing
  end
end

def step(op)
  if new_resource.skip.include?(op) then
    return
  end

  path = Pathname.new(new_resource.name)

  built = ::File.join(new_resource.name, "_#{op}")

  bash "#{op} #{path.basename}" do
    cwd new_resource.name
    environment new_resource.environment
    code eval("new_resource.#{op}") + " " + eval("new_resource.#{op}_extras")
    not_if "test -f #{built}"
  end

  if new_resource.patch_after == op then
    patch
  end

  file built do
    action :create_if_missing
  end
end

