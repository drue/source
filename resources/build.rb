actions :unpack, :configure, :build, :install

attribute :archive, :kind_of => String
attribute :configure, :default => "./configure"
attribute :configure_extras,  :default => ""
attribute :build, :default => "make"
attribute :build_extras, :default => ""
attribute :install, :default => "make install"
attribute :install_extras, :default => ""
attribute :environment, :default => {}
attribute :unpack_in, :kind_of => String
attribute :patches, :default => []
attribute :patch_extras, :default => "-N"
attribute :patch_after, :regex => /^(build)|(configure)|(unpack)/
attribute :patch_in, :kind_of => String
attribute :skip, :default => []

def initialize(*args)
  super
  @action = :install
  @patch_after = "unpack"
end
