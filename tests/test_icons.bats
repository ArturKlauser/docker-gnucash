#!/bin/env bats

load utils

@test "Checking that GTK can load SVG icons..." {
  exec_in_container /usr/bin/python3 -c '
import gi
gi.require_version("GdkPixbuf", "2.0")
from gi.repository import GdkPixbuf
loader = GdkPixbuf.PixbufLoader.new_with_type("svg")
loader.write(b"<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"1\" height=\"1\"><rect width=\"1\" height=\"1\"/></svg>")
loader.close()
assert loader.get_pixbuf() is not None
'
  assert_success
}

@test "Checking that app web icons are installed..." {
  icon_dir='/opt/noVNC/app/images/icons'
  exec_in_container test -d "${icon_dir}"
  assert_success # icons exists
  exec_in_container test -e "${icon_dir}/favicon.ico"
  assert_success # web favicon exists
}
