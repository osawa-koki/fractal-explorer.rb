require 'tomlrb'
require 'rmagick'
require 'bigdecimal/math'

config = Tomlrb.load_file('config.toml')

global_config = config['global']
pythagoras_tree_config = config['pythagoras_tree']

width = global_config['width'].to_i
height = global_config['height'].to_i
output_dir = global_config['output_dir']

$color_from = pythagoras_tree_config['color_from'].to_i
$color_upto = pythagoras_tree_config['color_upto'].to_i
size = pythagoras_tree_config['size'].to_i
degree = pythagoras_tree_config['degree'].to_i
$max_iterations = pythagoras_tree_config['max_iterations'].to_i
left = pythagoras_tree_config['left'].to_i
bottom = pythagoras_tree_config['bottom'].to_i
output_file = pythagoras_tree_config['output_file']

box_size = (width + height) / 2 * size / 100
left_size = width * left / 100
bottom_size = height * bottom / 100
$color_interval = ($color_upto - $color_from) / $max_iterations
$current_color = $color_from

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

def rec_draw(p1, p2, size, angle, degree, n, i, current_color)
  if n == 0
    return
  end

  color = "hsl(#{current_color % 360}, 100%, 50%)"

  # 左側
  smalled_size = Math.cos(degree * BigDecimal(Math::PI.to_s) / 180) * size
  points_left = get_left_points(p1[:x], p1[:y], smalled_size, angle, degree)
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
    current_color + $color_interval,
  )

  # 右側
  smalled_size = Math.sin(degree * BigDecimal(Math::PI.to_s) / 180) * size
  points_right = get_right_points(p2[:x], p2[:y], smalled_size, angle, degree)
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
    current_color + $color_interval,
  )
end

# ベースとなる四角形
draw = Magick::Draw.new
draw.fill("hsl(#{$current_color % 360}, 100%, 50%)")
draw.rectangle(
  left_size - box_size / 2,
  height - bottom_size - box_size,
  left_size + box_size / 2,
  height - bottom_size,
)
draw.draw($image)

# 再帰的に描写する四角形
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
  $current_color,
)

$image.write(File.join(output_dir, output_file))
