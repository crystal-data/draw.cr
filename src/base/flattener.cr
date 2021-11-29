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

# Receives segment definition
module Draw::Liner
  # Draw a line from the current position to the point (x, y)
  abstract def line_to(x : Float64, y : Float64)
end

module Draw::Flattener
  include Draw::Liner

  # Start a New line from the point (x, y)
  abstract def move_to(x : Float64, y : Float64)
  # Use Round, Bevel or miter to join points
  abstract def line_join
  # Add the most recent starting point to close the path to create a
  # polygon
  abstract def close
  # Mark the current line as finished so we can draw caps
  abstract def end_flattener
end

module Draw
  extend self

  def flatten(path : Draw::Path, flattener : Draw::Flattener, scale : Float64)
    start_x, start_y = 0_f64, 0_f64
    x, y = 0_f64, 0_f64
    i = 0

    path.components.each do |cmp|
      case cmp
      when Draw::PathComponent::MoveTo
        x, y = path.points[i], path.points[i + 1]
        start_x, start_y = x, y
        flattener.end if i != 0
        flattener.move_to(x, y)
        i += 2
      when Draw::PathComponent::LineTo
        x, y = path.points[i], path.points[i + 1]
        flattener.line_to(x, y)
        flattener.line_join
        i += 2
      when Draw::PathComponent::QuadCurveTo
        Draw.trace_quad(flattener, path.points[i - 2...], 0.5)
        x, y = path.points[i + 2], path.points[i + 3]
        flattener.line_to(x, y)
        i += 4
      when Draw::PathComponent::CubicCurveTo
        Draw.trace_cubic(flattener, path.points[i - 2...], 0.5)
        x, y = path.points[i + 4], path.points[i + 5]
        flattener.line_to(x, y)
        i += 6
      when Draw::PathComponent::ArcTo
        x, y = Draw.trace_arc(
          flattener,
          path.points[i],
          path.points[i + 1],
          path.points[i + 2],
          path.points[i + 3],
          path.points[i + 4],
          path.points[i + 5],
          scale
        )
        flattener.line_to(x, y)
        i += 6
      when Draw::PathComponent::Close
        flattener.line_to(start_x, start_y)
        flattener.close
      else
        raise "Invalid component"
      end
    end
    flattener.end
  end
end

class Draw::Transformer
  include Draw::Flattener

  getter tr : Draw::Matrix
  getter flattener : Draw::Flattener

  def initialize(@tr : Draw::Matrix, @flattener : Draw::Flattener)
  end

  def move_to(x : Float64, y : Float64)
    u = x*@tr[0] + y*@tr[2] + @tr[4]
    v = x*@tr[1] + y*@tr[3] + @tr[5]
    @flattener.move_to(u, v)
  end

  def line_to(x : Float64, y : Float64)
    u = x*@tr[0] + y*@tr[2] + @tr[4]
    v = x*@tr[1] + y*@tr[3] + @tr[5]
    @flattener.line_to(u, v)
  end

  delegate line_join, close, end_flattener, to: @flattener
end

class Draw::SegmentedPath
  include Draw::Flattener

  getter points : Array(Float64)

  def initialize(@points : Array(Float64))
  end

  def move_to(x : Float64, y : Float64)
    @points << x
    @points << y
  end

  def line_to(x : Float64, y : Float64)
    @points << x
    @points << y
  end

  def line_join; end

  def close; end

  def end_flattener; end
end
