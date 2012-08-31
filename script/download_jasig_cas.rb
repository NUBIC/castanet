#!/usr/bin/env ruby

require 'fileutils'
include FileUtils

URL = 'http://downloads.jasig.org/cas/cas-server-3.5.0-release.tar.gz'

DEST_DIR = File.expand_path("#{File.dirname(__FILE__)}/../tmp")
DEST_FILE = "#{DEST_DIR}/#{URL.split('/').last}"

cmds = [
  "wget #{URL} -O #{DEST_FILE}",
  "tar xf #{DEST_FILE} -C #{DEST_DIR}"
]

mkdir_p DEST_DIR

cmds.each do |cmd|
  puts cmd
  system(cmd)
end
