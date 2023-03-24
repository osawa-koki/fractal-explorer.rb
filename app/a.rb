require 'rmagick'
require 'bigdecimal/math'

width = 500
height = 500
color = 0
size = 15
degree = 60
$max_iterations = 10
left = 35
bottom = 20

$image = Magick::Image.new(width, height)

def get_left_points(x, y, size, angle, degree)
  [
    {x: x, y: y},
    {
      x: x + Math.cos((angle + degree) * BigDecimal(Math::PI.to_s) / 180) * size,
      y: y - Math.sin((angle + degree) * BigDecimal(Math::PI.to_s) / 180) * size,
    },
    {
      x: x + Math.cos((angle + degree + 45) * BigDecimal(Math::PI.to_s) / 180) * size * Math.sqrt(2),
      y: y - Math.sin((angle + degree + 45) * BigDecimal(Math::PI.to_s) / 180) * size * Math.sqrt(2),
    },
    {
      x: x + Math.cos((angle + degree + 90) * BigDecimal(Math::PI.to_s) / 180) * size,
      y: y - Math.sin((angle + degree + 90) * BigDecimal(Math::PI.to_s) / 180) * size,
    },
  ]
end

def get_right_points(x, y, size, angle, degree)
  [
    {x: x, y: y},
    {
      x: x + Math.cos((angle + degree) * BigDecimal(Math::PI.to_s) / 180) * size,
      y: y - Math.sin((angle + degree) * BigDecimal(Math::PI.to_s) / 180) * size,
    },
    {
      x: x + Math.cos((angle + degree + 45) * BigDecimal(Math::PI.to_s) / 180) * size * Math.sqrt(2),
      y: y - Math.sin((angle + degree + 45) * BigDecimal(Math::PI.to_s) / 180) * size * Math.sqrt(2),
    },
    {
      x: x + Math.cos((angle + degree + 90) * BigDecimal(Math::PI.to_s) / 180) * size,
      y: y - Math.sin((angle + degree + 90) * BigDecimal(Math::PI.to_s) / 180) * size,
    },
  ]
end

def rec_draw(p1, p2, size, angle, degree, n, i)
  if n == 0
    return
  end

  # 左側
  smalled_size = Math.cos(degree * BigDecimal(Math::PI.to_s) / 180) * size
  points_left = get_left_points(p1[:x], p1[:y], smalled_size, angle, degree)
  color = "hsl(#{(320 / ($max_iterations + 1) * i + 0) % 360}, 100%, 50%)"
  draw = Magick::Draw.new
  draw.fill(color)
  draw.polygon(*points_left.map { |p| [p[:x], p[:y]] }.flatten)
  draw.draw($image)
  rec_draw(
    { x: points_left[3][:x], y: points_left[3][:y] },
    { x: points_left[2][:x], y: points_left[2][:y] },
    smalled_size,
    angle + degree,
    degree,
    n - 1,
    i + 1,
  )

  # 右側
  smalled_size = Math.sin(degree * BigDecimal(Math::PI.to_s) / 180) * size
  points_right = get_right_points(p2[:x], p2[:y], smalled_size, angle, degree)
  color = "hsl(#{(320 / ($max_iterations + 1) * i + 0) % 360}, 100%, 50%)"
  draw = Magick::Draw.new
  draw.fill(color)
  draw.polygon(*points_right.map { |p| [p[:x], p[:y]] }.flatten)
  draw.draw($image)
  rec_draw(
    { x: points_right[2][:x], y: points_right[2][:y] },
    { x: points_right[1][:x], y: points_right[1][:y] },
    smalled_size,
    angle - (90 - degree),
    degree,
    n - 1,
    i + 1,
  )
end

box_size = (width + height) / 2 * size / 100
left_size = width * left / 100
bottom_size = height * bottom / 100

draw = Magick::Draw.new
draw.fill('red')
draw.rectangle(
  left_size - box_size / 2,
  height - bottom_size - box_size,
  left_size + box_size / 2,
  height - bottom_size,
)
draw.draw($image)

rec_draw(
  {
    x: left_size - box_size / 2,
    y: height - bottom_size - box_size,
  },
  {
    x: left_size - box_size / 2 + box_size,
    y: height - bottom_size - box_size,
  },
  box_size,
  0,
  degree,
  $max_iterations,
  1,
)

$image.write('out.png')
