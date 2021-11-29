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

enum Draw::FillRule
  # EvenOdd determines the "insideness" of a point in the shape
  # by drawing a ray from that point to infinity in any direction
  # and counting the number of path segments from the given shape that the ray crosses.
  # If this number is odd, the point is inside; if even, the point is outside.
  EvenOdd

  # Winding determines the "insideness" of a point in the shape
  # by drawing a ray from that point to infinity in any direction
  # and then examining the places where a segment of the shape crosses the ray.
  # Starting with a count of zero, add one each time a path segment crosses
  # the ray from left to right and subtract one each time
  # a path segment crosses the ray from right to left. After counting the crossings,
  # if the result is zero then the point is outside the path. Otherwise, it is inside.
  Winding
end

enum Draw::LineCap
  # Round defines a rounded shape at the end of the line
  Round

  # Butt defines a squared shape exactly at the end of the line
  Butt

  # Square defines a squared shape at the end of the line
  Square
end

enum Draw::LineJoin
  # Bevel represents cut segments joint
  Bevel

  # Round represents rounded segments joint
  Round

  # Miter represents peaker segments joint
  Miter
end

# StrokeStyle keeps stroke style attributes
# that is used by the Stroke method of a Drawer
struct Draw::StrokeStyle
  # Color defines the color of stroke
  getter color : Colorize::Color

  # Line width
  getter width : Float64

  # Line cap style rounded, butt or square
  getter line_cap : Draw::LineCap

  # Line join style bevel, round or miter
  getter line_join : Draw::LineJoin

  # Offset of the first dash
  getter dash_offset : Float64

  # Array represented dash length pair values are plain dash and impair are space between dash
  # if empty display plain line
  getter dash : Array(Float64)

  def initialize(
    @color : Colorize::Color,
    @width : Float64,
    @line_cap : Draw::LineCap,
    @line_join : Draw::LineJoin,
    @dash_offset : Float64,
    @dash : Array(Float64)
  )
  end
end

# SolidFillStyle define style attributes for a solid fill style
struct Draw::SolidFillStyle
  # Color defines the line color
  getter color : Colorize::Color

  # fill_rule defines the file rule to used
  getter fill_rule : Draw::FillRule

  def initialize(@color : Colorize::Color, @fill_rule : Draw::FillRule)
  end
end

# Vertical Alignment of the text
enum Draw::VAlign
  # Top aligned text
  Top

  # Centered text
  Center

  # Bottom aligned text
  Bottom

  # Align text with baseline of the font
  Baseline
end

# Horizontal Alignment of the text
enum Draw::HAlign
  # Horizontally align to left
  Left

  # Horizontally align to center
  Center

  # Horizontally align to right
  Right
end

# ScalingPolicy is a constant to define how to scale an image
enum Draw::ScalingPolicy
  # No scaling applied
  None

  # the image is stretched so that its width and height are exactly
  # the given width and height
  Stretch

  # The image is scaled so that its width is exactly the given width
  Width

  # The image is scaled so that its height is exactly the given height
  Height

  # The image is scaled to the largest scale that allow the image to
  # fit within a rectangle width x height
  Fit

  # The image is scaled so that its area is exactly the area of the
  # given rectangle width x height
  SameArea

  # The image is scaled to the smallest scale that allow the image to
  # fully cover a rectangle width x height
  Fill
end

# ImageScaling style attributes used to display the image
struct Draw::ImageScaling
  # Horizontal Alignment of the image
  getter h_align : Draw::HAlign

  # Vertical Alignment of the image
  getter v_align : Draw::VAlign

  # Width used by scaling policy
  getter width : Float64

  # Height used by scaling policy
  getter height : Float64

  # Defines the scaling policy to applied to the image
  getter scaling_policy : Draw::ScalingPolicy

  def initialize(
    @h_align : Draw::HAlign,
    @v_align : Draw::VAlign,
    @width : Float64,
    @height : Float64,
    @scaling_policy : Draw::ScalingPolicy
  )
  end
end
