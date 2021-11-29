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

module Draw
  extend self
  CURVE_RECURSION_LIMIT = 32

  # Subdivide a Bezier cubic curve in 2 equivalents Bezier cubic curves.
  # c1 and c2 parameters are the resulting curves
  # length of c, c1 and c2 must be 8
  def subdivide_cubic(
    c : Array(Float64),
    c1 : Array(Float64),
    c2 : Array(Float64)
  )
    # First point of c is the first point of c1
    c1[0], c1[1] = c[0], c[1]
    # Last point of c is the last point of c2
    c2[6], c2[7] = c[6], c[7]

    # Subdivide segment using midpoints
    c1[2] = (c[0] + c[2]) / 2
    c1[3] = (c[1] + c[3]) / 2

    mid_x = (c[2] + c[4]) / 2
    mid_y = (c[3] + c[5]) / 2

    c2[4] = (c[4] + c[6]) / 2
    c2[5] = (c[5] + c[7]) / 2

    c1[4] = (c1[2] + mid_x) / 2
    c1[5] = (c1[3] + mid_y) / 2

    c2[2] = (mid_x + c2[4]) / 2
    c2[3] = (mid_y + c2[5]) / 2

    c1[6] = (c1[4] + c2[2]) / 2
    c1[7] = (c1[5] + c2[3]) / 2

    # Last Point of c1 is equal to the first point of c2
    c2[0], c2[1] = c1[6], c1[7]
  end

  # TraceCubic generate lines subdividing the cubic curve using a Liner
  # flattening_threshold helps determines the flattening expectation
  # of the curve
  def trace_cubic(
    t : Draw::Liner,
    cubic : Array(Float64),
    flattening_threshold : Float64
  )
    unless cubic.size >= 8
      raise "Cubic length must be >= 8"
    end

    curves = Array(Float64).new(CURVE_RECURSION_LIMIT * 8)
    curves[...8] = cubic[...8]

    i = 0
    c = [] of Float64

    dx, dy, d2, d3 = 0_f64, 0_f64, 0_f64, 0_f64

    while i >= 0
      c = curves[i...]
      dx = c[6] - c[0]
      dy = c[7] - c[1]

      d2 = ((c[2] - c[6])*dy - (c[3] - c[7])*dx).abs
      d3 = ((c[4] - c[6])*dy - (c[5] - c[7])*dx).abs

      # if it's flat then trace a line
      if (d2 + d3)*(d2 + d3) <= flattening_threshold*(dx*dx + dy*dy) || i == curves.size - 8
        t.line_to(c[6], c[7])
        i -= 8
      else
        # Second half of bezier go lower onto the stack
        Draw.subdivide_cubic(c, curves[i + 8...], curves[i...])
        i += 8
      end
    end
  end

  # Quad
  # x1, y1, cpx1, cpy2, x2, y2 float64
  #
  # Subdivide a Bezier quad curve in 2 equivalents Bezier quad curves.
  # c1 and c2 parameters are the resulting curves
  # length of c, c1 and c2 must be 6
  def subdivide_cubic(
    c : Array(Float64),
    c1 : Array(Float64),
    c2 : Array(Float64)
  )
    # First point of c is the first point of c1
    c1[0], c1[1] = c[0], c[1]
    # Last point of c is the last point of c2
    c2[4], c2[5] = c[4], c[5]

    # Subdivide segment using midpoints
    c1[2] = (c[0] + c[2]) / 2
    c1[3] = (c[1] + c[3]) / 2
    c2[2] = (c[2] + c[4]) / 2
    c2[3] = (c[3] + c[5]) / 2
    c1[4] = (c1[2] + c2[2]) / 2
    c1[5] = (c1[3] + c2[3]) / 2
    c2[0], c2[1] = c1[4], c1[5]
  end

  # TraceQuad generate lines subdividing the curve using a Liner
  # flattening_threshold helps determines the flattening expectation
  # of the curve
  def trace_quad(t : Draw::Liner, quad : Array(Float64), flattening_threshold : Float64)
    if len(quad) < 6
      raise "Quad length must be >= 6"
    end
    # Allocates curves stack
    curves = Array(Float64).new(CURVE_RECURSION_LIMIT * 6)
    curves[0...6] = quad[0...6]

    i = 0
    c = [] of Float64
    dx, dy, d = 0_f64, 0_f64, 0_f64

    while i >= 0
      c = curves[i...]
      dx = c[4] - c[0]
      dy = c[5] - c[1]

      d = (((c[2] - c[4])*dy - (c[3] - c[5])*dx)).abs

      # if it's flat then trace a line
      if (d*d) <= flattening_threshold*(dx*dx + dy*dy) || i == curves.size - 6
        t.line_to(c[4], c[5])
        i -= 6
      else
        # Second half of bezier go lower onto the stack
        subdivide_quad(c, curves[i + 6...], curves[i...])
        i += 6
      end
    end
  end

  # TraceArc trace an arc using a Liner
  def trace_arc(
    t : Draw::Liner,
    x : Float64,
    y : Float64,
    rx : Float64,
    ry : Float64,
    start : Float64,
    angle : Float64,
    scale : Float64
  )
    end_angle = start + angle
    clock_wise = true
    if angle < 0
      clock_wise = false
    end
    ra = (rx.abs + ry.abs) / 2
    da = Math.acos(ra/(ra + 0.125/scale)) * 2
    # normalize
    if !clock_wise
      da = -da
    end

    angle = start + da
    cur_x, cur_y = 0_f64, 0_f64

    while true
      if (angle < end_angle - da/4) != clock_wise
        cur_x = x + Math.cos(end_angle)*rx
        cur_y = y + Math.sin(end_angle)*ry
        return cur_x, cur_y
      end
      cur_x = x + Math.cos(angle)*rx
      cur_y = y + Math.sin(angle)*ry

      angle += da
      t.line_to(cur_x, cur_y)
    end
  end
end
