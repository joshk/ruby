#!./miniruby -I.

require "rbconfig.rb"
include Config

$:.unshift CONFIG["srcdir"]+"/lib"
require "ftools"

binsuffix = CONFIG["binsuffix"]
if ENV["prefix"]
  prefix = ENV["prefix"]
else
  prefix = CONFIG["prefix"]
end
ruby_install_name = CONFIG["ruby_install_name"]
bindir = prefix + "/bin"
libdir = prefix + "/lib/" + ruby_install_name
archdir = libdir+"/"+CONFIG["arch"]
mandir = prefix + "/man/man1"

File.makedirs bindir, TRUE
File.install "ruby#{binsuffix}",
  "#{bindir}/#{ruby_install_name}#{binsuffix}", 0755, TRUE
for dll in Dir['*.dll']
  File.install dll, "#{bindir}/#{dll}", 0755, TRUE
end
File.makedirs "#{prefix}/lib", TRUE
for lib in ["libruby.so", "libruby.so.LIB"]
  if File.exist? lib
    File.install lib, "#{prefix}/lib", 0644, TRUE
  end
end
File.makedirs libdir, TRUE
Dir.chdir "ext"
system "../miniruby#{binsuffix} extmk.rb install"
Dir.chdir CONFIG["srcdir"]
IO.foreach 'MANIFEST' do |$_|
  $_.chop!
  if /^lib/
    File.install $_, libdir, 0644, TRUE
  elsif /^[a-z]+\.h$/
    File.install $_, archdir, 0644, TRUE
  end
  File.install "config.h", archdir, 0644, TRUE
end
File.install "rbconfig.rb", archdir, 0644, TRUE
File.makedirs mandir, TRUE
File.install "ruby.1", mandir, 0644, TRUE
# vi:set sw=2:
