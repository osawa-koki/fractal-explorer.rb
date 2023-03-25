require 'tomlrb'
require 'rmagick'
require 'bigdecimal/math'

config = Tomlrb.load_file('config.toml')

global_config = config['global']
koch_snowflake_config = config['koch_snowflake']

width = global_config['width'].to_i
height = global_config['height'].to_i
output_dir = global_config['output_dir']

color = koch_snowflake_config['color']
background_color = koch_snowflake_config['background_color']
triagle_size = koch_snowflake_config['triagle_size'].to_i
max_iterations = koch_snowflake_config['max_iterations'].to_i
$divition = koch_snowflake_config['divition'].to_i
$bottom_adjuster = koch_snowflake_config['bottom_adjuster'].to_f
output_file = koch_snowflake_config['output_file']

canvas_size = ((width + height) / 2)

$image = Magick::Image.new(width, height)

def calc_points(a, b, points, n)
  if n == 0
    return
  end
  s = {
    x: a[:x] + (b[:x] - a[:x]) / $divition,
    y: a[:y] + (b[:y] - a[:y]) / $divition,
  }
  t = {
    x: a[:x] + (b[:x] - a[:x]) * 2 / $divition,
    y: a[:y] + (b[:y] - a[:y]) * 2 / $divition,
  }
  u = {
    x: s[:x] + (t[:x] - s[:x]) * Math.cos(BigDecimal(Math::PI.to_s) / 3) - (t[:y] - s[:y]) * Math.sin(BigDecimal(Math::PI.to_s) / 3),
    y: s[:y] + (t[:x] - s[:x]) * Math.sin(BigDecimal(Math::PI.to_s) / 3) + (t[:y] - s[:y]) * Math.cos(BigDecimal(Math::PI.to_s) / 3),
  }
  calc_points(a, s, points, n - 1)
  points << s
  calc_points(s, u, points, n - 1)
  points << u
  calc_points(u, t, points, n - 1)
  points << t
  calc_points(t, b, points, n - 1)
end

def object_to_array(object)
  return [object[:x], object[:y]]
end

size = canvas_size * triagle_size / 100
start = canvas_size - (Math.sqrt(3) * canvas_size * triagle_size / 100 / 2) - (canvas_size / $bottom_adjuster) / 2

_a = {
  x: canvas_size / 2,
  y: start,
}
_b = {
  x: canvas_size / 2 - size / 2,
  y: start + Math.sqrt(3) * size / 2,
}
_c = {
  x: canvas_size / 2 + size / 2,
  y: start + Math.sqrt(3) * size / 2,
}

for i in 1..max_iterations
  points = []
  calc_points(_a, _b, points, i)
  calc_points(_b, _c, points, i)
  calc_points(_c, _a, points, i)
  points = points.map { |point| object_to_array(point) }
  draw = Magick::Draw.new
  draw.fill(color)
  draw.polyline(*points.flatten)
  draw.draw($image)
end

$image.write(File.join(output_dir, output_file))
