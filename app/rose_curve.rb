require 'tomlrb'
require 'rmagick'
require 'bigdecimal/math'

config = Tomlrb.load_file('config.toml')

global_config = config['global']
rose_curve_config = config['rose_curve']

width = global_config['width'].to_i
height = global_config['height'].to_i
output_dir = global_config['output_dir']

n = rose_curve_config['n'].to_i
k = rose_curve_config['k'].to_i
size = rose_curve_config['size'].to_i
step = rose_curve_config['step'].to_f
$radius = rose_curve_config['radius'].to_f
background_color = rose_curve_config['background_color']
output_file = rose_curve_config['output_file']

canvas_size = ((width + height) / 2)

$image = Magick::Image.new(width, height)

color = 0
for i in 0..360 * n
  degree = i * BigDecimal(Math::PI.to_s) / 180
  x = Math.sin((n * i / k) * BigDecimal(Math::PI.to_s) / 180) * Math.cos(degree)
  y = Math.sin((n * i / k) * BigDecimal(Math::PI.to_s) / 180) * Math.sin(degree)
  zoom = canvas_size / 2 * size / 100
  color = (color + 1) % 360
  draw = Magick::Draw.new
  draw.fill("hsl(#{color}, 100%, 50%)")
  draw.circle(x * zoom + canvas_size / 2, y * zoom + canvas_size / 2, x * zoom + canvas_size / 2 + $radius, y * zoom + canvas_size / 2 + $radius)
  draw.draw($image)
end

$image.write(File.join(output_dir, output_file))
