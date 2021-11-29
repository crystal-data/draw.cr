# Copyright (c) 2021 Crystal Data Contributors
#
# MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module Draw::GraphicContext
  # Describes the interface for path drawing
  include Draw::PathBuilder

  # Creates a new path
  abstract def begin_path
  # Copies the current path, then returns it
  abstract def path : Draw::Path
  # Returns the current transformation matrix
  abstract def matrix_transform : Draw::Matrix
  # Sets the current transformation matrix
  abstract def matrix_transform(tr : Draw::Matrix)
  # Composes the current transformation matrix with tr
  abstract def compose_matrix_transform(tr : Draw::Matrix)
  # Applies a rotation to the current transformation matrix. angle is in radian.
  abstract def totate(angle : Float64)
  # Applies a translation to the current transformation matrix.
  abstract def translate(tx : Float64, ty : Float64)
  # Applies a scale to the current transformation matrix.
  abstract def scale(sx : Float64, sy : Float64)
  # Sets the current stroke color
  abstract def stroke_color(c : Colorize::Color)
  # Sets the current fill color
  abstract def fill_color(c : Colorize::Color)
  # Sets the current fill rule
  abstract def fill_rule(f : Draw::FillRule)
  # Sets the current line width
  abstract def line_width(line_width : Float64)
  # Sets the current line cap
  abstract def line_cap(cap : Draw::LineCap)
  # Sets the current line join
  abstract def line_join(join : Draw::LineJoin)
  # Sets the current dash
  abstract def line_dash(dash : Array(Float64), dash_offset : Float64)
  # Sets the current font size
  abstract def font_size(font_size : Float64)
  # Gets the current font size
  abstract def font_size : Float64
  # Sets the current FontData
  abstract def font_data(font_data : Draw::FontData)
  # Gets the current FontData
  abstract def font_data : Draw::FontData
  # Gets the current FontData as a string
  abstract def font_name : String
  # Draws the raster image in the current canvas
  # abstract def draw_image(image image.Image)
  # Save the context and push it to the context stack
  abstract def save
  # Remove the current context and restore the last one
  abstract def restore
  # Fills the current canvas with a default transparent color
  abstract def clear
  # Fills the specified rectangle with a default transparent color
  abstract def clear_rect(x1 : Int32, y1 : Int32, x2 : Int32, y2 : Int32)
  # Sets the current DPI
  abstract def dpi(dpi : Int32)
  # Gets the current DPI
  abstract def dpi : Int32
  # Gets pixel bounds(dimensions) of given string
  abstract def string_bounds(s : String) : Tuple(Float64, Float64, Float64, Float64)
  # Creates a path from the string s at x, y
  abstract def create_string_path(text : String, x : Float64, y : Float64) : Float64
  # Draws the text at point (0, 0)
  abstract def fill_string(text : String) : Float64
  # Draws the text at the specified point (x, y)
  abstract def fill_string_at(text : String, x : Float64, y : Float64) : Float64
  # Draws the contour of the text at point (0, 0)
  abstract def stroke_string(text : String) : Float64
  # Draws the contour of the text at point (x, y)
  abstract def stroke_string_at(text : String, x : Float64, y : Float64) : Float64
  # Strokes the paths with the color specified by stroke_color
  abstract def stroke(*paths : Draw::Path)
  # Fills the paths with the color specified by fill_color
  abstract def fill(*paths : Draw::Path)
  # First fills the paths and than strokes them
  abstract def fill_stroke(*paths : Draw::Path)
end
