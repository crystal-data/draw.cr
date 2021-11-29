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

class Draw::DashVertexConverter
  include Draw::Flattener

  getter next_flattener : Draw::Flattener
  getter x : Float64 = 0_f64
  getter y : Float64 = 0_f64
  getter distance : Float64 = 0_f64
  getter dash : Array(Float64)
  getter current_dash : Int32 = 0
  getter dash_offset : Float64

  def initialize(@dash : Array(Float64), @dash_offset : Float64, @next_flattener : Draw::Flattener)
  end

  def line_to(x : Float64, y : Float64)
    rest = @dash[dasher.current_dash] - @distance
    while rest < 0
      @distance = @distance - @dash[dasher.current_dash]
      @current_dash = (@current_dash + 1) % @dash.size
      rest = @dash[@current_dash] - @distance
    end

    d = Draw.distance(@x, @y, x, y)

    while d >= rest
      k = rest / d
      lx = @x + k*(x - @x)
      ly = @y + k*(y - @y)

      if @current_dash % 2 == 0
        # line
        @next_flattener.line_to(lx, ly)
      else
        # gap
        @next_flattener.end
        @next_flattener.move_to(lx, ly)
      end

      d = d - rest
      @x, @y = lx, ly
      @current_dash = (@current_dash + 1) % @dash.size
      rest = @dash[@current_dash]
    end

    @distance = d

    if @current_dash % 2 == 0
      # line
      @next_flattener.line_to(x, y)
    else
      # gap
      @next_flattener.end
      @next_flattener.move_to(x, y)
    end

    if @distance >= @dash[@current_dash]
      @distance = @distance - @dash[@current_dash]
      @current_dash = (@current_dash + 1) % @dash.size
    end

    @x, @y = x, y
  end

  def move_to(x : Float64, y : Float64)
    @next_flattener.move_to(x, y)
    @x, @y = x, y
    @distance = @dash_offset
    @current_dash = 0
  end

  delegate line_join, close, end_flattener, to: @next_flattener
end
