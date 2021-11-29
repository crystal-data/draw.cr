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

# PathBuilder describes the interface for path drawing.
module Draw::PathBuilder
  # Returns the current point of the current sub path
  abstract def last_point : Tuple(Float64, Float64)
  # Creates a new subpath that start at the specified point
  abstract def move_to(x : Float64, y : Float64)
  # Adds a line to the current subpath
  abstract def line_to(x : Float64, y : Float64)
  # Adds a quadratic Bézier curve to the current subpath
  abstract def quad_curve_to(cx : Float64, cy : Float64, x : Float64, y : Float64)
  # Adds a cubic Bézier curve to the current subpath
  abstract def cubic_curve_to(cx1 : Float64, cy1 : Float64, cx2 : Float64, cy2 : Float64, x : Float64, y : Float64)
  # Adds an arc to the current subpath
  abstract def arc_to(cx : Float64, cy : Float64, rx : Float64, ry : Float64, start_angle : Float64, angle : Float64)
  # Creates a line from the current point to the last MoveTo
  # point (if not the same) and mark the path as closed so the
  # first and last lines join nicely.
  abstract def close
end

# Represents components in a Path
enum Draw::PathComponent
  # MoveTo component in a Path
  MoveTo
  # LineTo component in a Path
  LineTo
  # QuadCurveTo component in a Path
  QuadCurveTo
  # CubicCurveTo component in a Path
  CubicCurveTo
  # ArcTo component in a Path
  ArcTo
  # ArcTo component in a Path
  Close
end

class Draw::Path
  include Draw::PathBuilder
  # Array of PathComponents in a Path and mark the role of each points
  # in the Path
  getter components : Array(Draw::PathComponent)

  # points are combined with components to have a specific role in the
  # path
  getter points : Array(Float64)

  # X-coordinate of the last point in a path
  getter x : Float64

  # Y-coordinate of the last point in a path
  getter y : Float64

  def initialize
    @components = Array(Draw::PathComponent).new
    @points = Array(Float64).new
    @x = 0.0
    @y = 0.0
  end

  def initialize(
    @components : Array(Draw::PathComponent),
    @points : Array(Float64),
    @x : Float64,
    @y : Float64
  )
  end

  def append(cmd : Draw::PathComponent, *new_points : Float64)
    @components << cmd
    @points.concat(new_points)
  end

  # Returns the current point of the current path
  def last_point : Tuple(Float64, Float64)
    {@x, @y}
  end

  # Starts a new path at (x, y) position
  def move_to(x : Float64, y : Float64)
    self.append(Draw::PathComponent::MoveTo, x, y)
    @x = x
    @y = y
  end

  # Adds a line to the current path
  def line_to(x : Float64, y : Float64)
    if @components.size == 0
      self.move_to(x, y)
    else
      self.append(Draw::PathComponent::LineTo, x, y)
    end
    @x = x
    @y = y
  end

  # Adds a quadratic bezier curve to the current path
  def quad_curve_to(cx : Float64, cy : Float64, x : Float64, y : Float64)
    if @components.size == 0
      self.move_to(x, y)
    else
      self.append(Draw::PathComponent::QuadCurveTo, cx, cy, x, y)
    end
    @x = x
    @y = y
  end

  # Adds a cubic bezier curve to the current path
  def cubic_curve_to(cx1 : Float64, cy1 : Float64, cx2 : Float64, cy2 : Float64, x : Float64, y : Float64)
    if @components.size == 0
      self.move_to(x, y)
    else
      self.append(Draw::PathComponent::CubicCurveTo, cx1, cy1, cx2, cy2, x, y)
    end
    @x = x
    @y = y
  end

  # Adds an arc to the path
  def arc_to(cx : Float64, cy : Float64, rx : Float64, ry : Float64, start_angle : Float64, angle : Float64)
    end_angle = start_angle + angle
    clock_wise = true

    if angle < 0
      clock_wise = false
    end

    if clock_wise
      while end_angle < start_angle
        end_angle += Math::PI * 2.0
      end
    else
      while start_angle < end_angle
        start_angle += Math::PI * 2.0
      end
    end

    start_x = cx + Math.cos(start_angle) * rx
    start_y = cy + Math.sin(start_angle) * ry
    if @components.size > 0
      self.line_to(start_x, start_y)
    else
      self.move_to(start_x, start_y)
    end
    self.append(Draw::PathComponent::ArcTo, cx, cy, rx, ry, start_angle, angle)
    @x = cx + Math.cos(end_angle) * rx
    @y = cy + Math.sin(end_angle) * ry
  end

  # Closes the path
  def close
    self.append(Draw::PathComponent::Close)
  end

  # Duplicates a path
  def dup
    new(@components.dup, @points.dup, x, y)
  end

  # Clears the components from a path
  def clear
    @components = Array(Draw::PathComponent).new
    @points = Array(Float64).new
  end

  # Determines if the Path is empty or not
  def empty?
    @components.size == 0
  end

  # Returns a new Path with a flipped y-axis
  def vertical_flip : Draw::Path
    path = self.dup
    i = 0
    path.components.each do |cmp|
      case cmp
      when {Draw::PathComponent::MoveTo, Draw::PathComponent::LineTo}
        path.points[i + 1] = -path.points[i + 1]
        i += 2
      when Draw::PathComponent::QuadCurveTo
        path.points[i + 1] = -path.points[i + 1]
        path.points[i + 3] = -path.points[i + 3]
        i += 4
      when Draw::PathComponent::CubicCurveTo
        path.points[i + 1] = -path.points[i + 1]
        path.points[i + 3] = -path.points[i + 3]
        path.points[i + 5] = -path.points[i + 5]
        i += 6
      when Draw::PathComponent::ArcTo
        path.points[i + 1] = -path.points[i + 1]
        path.points[i + 3] = -path.points[i + 3]
        path.points[i + 4] = -path.points[i + 4]
        path.points[i + 5] = -path.points[i + 5]
        i += 6
      else
      end
    end
    @y = -@y
    path
  end
end
