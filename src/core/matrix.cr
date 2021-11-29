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

class Draw::Matrix
  @tr : StaticArray(Float64, 6)

  private def initialize(a, b, c, d, e, f)
    @tr = StaticArray[a, b, c, d, e, f]
  end

  # Indexes the underlying static array backing a Matrix
  def [](i : Int)
    @tr[i]
  end

  private def initialize(@tr : StaticArray(Float64, 6))
  end

  # Creates an identity transformation matrix.
  def self.identity
    new(1.0, 0.0, 0.0, 1.0, 0.0, 0.0)
  end

  # Creates a transformation matrix with a translation tx and
  # ty translation parameter
  def self.translation(tx : Float64, ty : Float64)
    new(1.0, 0.0, 0.0, 1.0, tx, ty)
  end

  # Creates a transformation matrix with a sx, sy scale factor
  def self.scale(sx : Float64, sy : Float64)
    new(sx, 0.0, 0.0, sy, 0.0, 0.0)
  end

  # Creates a rotation transformation matrix. angle is in radian
  def self.rotation(angle : Float64)
    c = Math.cos(angle)
    s = Math.sin(angle)
    new(c, s, -s, c, 0.0, 0.0)
  end

  # Creates a transformation matrix, combining a scale and a translation,
  # that transform r1 into r2.
  def self.from_rects(r1 : StaticArray(Float64, 4), r2 : StaticArray(Float64, 4))
    x_scale = (r2[2] - r2[0]) / (r1[2] - r1[0])
    y_scale = (r2[3] - r2[1]) / (r1[3] - r1[1])
    x_offset = r2[0] - (r1[0] * x_scale)
    y_offset = r2[1] - (r1[1] * y_scale)
    new(x_scale, 0.0, 0.0, y_scale, x_offset, y_offset)
  end

  # Compute the determinant of the matrix
  def determinant : Float64
    @tr[0] * @tr[3] - @tr[1]*@tr[2]
  end

  # Applies the transformation matrix to points. It modify the
  # points passed in parameter.
  def transform(points : Array(Float64))
    n = points.size
    0.step(by: 2, to: n - 1).zip(1.step(to: n, by: 2)) do |i, j|
      x = points[i]
      y = points[j]
      points[i] = x*@tr[0] + y*@tr[2] + @tr[4]
      points[j] = x*@tr[1] + y*@tr[3] + @tr[5]
    end
  end

  # Applies the transformation matrix to point. It returns the
  # point the transformed point.
  def transform_point(x : Float64, y : Float64)
    xres = x*@tr[0] + y*@tr[2] + @tr[4]
    yres = x*@tr[1] + y*@tr[3] + @tr[5]
    {xres, yres}
  end

  # Applies the transformation matrix to the rectangle represented
  # by the min and the max point of the rectangle.
  def transform_rectangle(x0 : Float64, y0 : Float64, x2 : Float64, y2 : Float64)
    points = [x0, y0, x2, y0, x2, y2, x0, y2]
    self.transform(points)
    points[0], points[2] = {points[0], points[2]}.minmax
    points[4], points[6] = {points[4], points[6]}.minmax
    points[1], points[3] = {points[1], points[3]}.minmax
    points[5], points[7] = {points[5], points[7]}.minmax

    nx0 = {points[0], points[4]}.min
    ny0 = {points[1], points[5]}.min
    nx2 = {points[2], points[6]}.max
    ny2 = {points[3], points[7]}.max
    {nx0, ny0, nx2, ny2}
  end

  # Applies the transformation inverse matrix to the rectangle
  # represented by the min and the max point of the rectangle
  def inverse_transform(points : Array(Float64))
    d = self.determinant
    n = points.size
    0.step(by: 2, to: n - 1).zip(1.step(to: n, by: 2)) do |i, j|
      x = points[i]
      y = points[j]
      points[i] = ((x - @tr[4])*@tr[3] - (y - @tr[5])*@tr[2]) / d
      points[j] = ((y - @tr[5])*@tr[0] - (x - @tr[4])*@tr[1]) / d
    end
  end

  # Applies the transformation inverse matrix to point. It returns
  # the point the transformed point.
  def inverse_transform_point(x : Float64, y : Float64)
    d = self.determinant
    xres = ((x - @tr[4])*@tr[3] - (y - @tr[5])*@tr[2]) / d
    yres = ((y - @tr[5])*@tr[0] - (x - @tr[4])*@tr[1]) / d
    {xres, yres}
  end

  # Applies the transformation matrix to points without using the
  # translation parameter of the affine matrix. It modifies the points
  # passed in parameter.
  def vector_transform(points : Array(Float64))
    n = points.size
    0.step(by: 2, to: n - 1).zip(1.step(to: n, by: 2)) do |i, j|
      x = points[i]
      y = points[j]
      points[i] = x*@tr[0] + y*@tr[2]
      points[j] = x*@tr[1] + y*@tr[3]
    end
  end

  # Computes the matrix inverse
  def inverse
    d = self.determinant
    tr0, tr1, tr2, tr3, tr4, tr5 = @tr
    @tr[0] = tr3 / d
    @tr[1] = -tr1 / d
    @tr[2] = -tr2 / d
    @tr[3] = tr0 / d
    @tr[4] = (tr2*tr5 - tr3*tr4) / d
    @tr[5] = (tr1*tr4 - tr0*tr5) / d
  end

  # Copies a matrix
  def dup
    new(@tr.clone)
  end

  # Multiplies another matrix to self
  def compose(m : Draw::Matrix)
    tr0, tr1, tr2, tr3, tr4, tr5 = @tr
    @tr[0] = m[0]*tr0 + m[1]*tr2
    @tr[1] = m[1]*tr3 + m[0]*tr1
    @tr[2] = m[2]*tr0 + m[3]*tr2
    @tr[3] = m[3]*tr3 + m[2]*tr1
    @tr[4] = m[4]*tr0 + m[5]*tr2 + tr4
    @tr[5] = m[5]*tr3 + m[4]*tr1 + tr5
  end

  # Adds a scale to the matrix
  def scale(sx : Float64, sy : Float64)
    @tr[0] *= sx
    @tr[1] *= sx
    @tr[2] *= sy
    @tr[3] *= sy
  end

  # Adds a translation to the matrix
  def translate(tx : Float64, ty : Float64)
    @tr[4] = tx*@tr[0] + ty*@tr[2] + @tr[4]
    @tr[5] = ty*@tr[3] + tx*@tr[1] + @tr[5]
  end

  # Adds a rotation to the matrix. angle is in radian
  def rotate(angle : Float64)
    c = Math.cos(angle)
    s = Math.sin(angle)
    t0 = c*@tr[0] + s*@tr[2]
    t1 = s*@tr[3] + c*@tr[1]
    t2 = c*@tr[2] - s*@tr[0]
    t3 = c*@tr[3] - s*@tr[1]
    @tr[0] = t0
    @tr[1] = t1
    @tr[2] = t2
    @tr[3] = t3
  end

  # Returns the translation of a matrix
  def translation
    {@tr[4], @tr[5]}
  end

  # Returns the scaling factors of a matrix
  def scaling
    {@tr[0], @tr[3]}
  end

  # Returns the scale of a matrix
  def scale
    x = 0.707106781*@tr[0] + 0.707106781*@tr[1]
    y = 0.707106781*@tr[2] + 0.707106781*@tr[3]
    Math.sqrt(x*x + y*y)
  end
end
