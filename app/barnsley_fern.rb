require 'tomlrb'
require 'rmagick'

config = Tomlrb.load_file('config.toml')

global_config = config['global']
barnsley_fern_config = config['barnsley_fern']

width = global_config['width'].to_i
height = global_config['height'].to_i
output_dir = global_config['output_dir']

size_x = barnsley_fern_config['size_x'].to_f
size_y = barnsley_fern_config['size_y'].to_f
start_x = barnsley_fern_config['start_x'].to_f
start_y = barnsley_fern_config['start_y'].to_f
zoom = barnsley_fern_config['zoom'].to_f
max_iterations = barnsley_fern_config['max_iterations'].to_i
color = barnsley_fern_config['color']
background_color = barnsley_fern_config['background_color']
output_file = barnsley_fern_config['output_file']

image = Magick::Image.new(width, height)

x, y = 0, 0

(0...max_iterations).each do |i|
  px = (zoom * x + start_x * width / 100).to_i
  py = (height - ((size_y * height / 1000) * y + (start_y * height / 100)).to_i)
  image.pixel_color(px, py, color)

  r = rand(100)
  xn, yn = x, y
  if r < 1
    x = 0
    y = 0.16 * yn
  elsif r < 86
    x = 0.85 * xn + 0.04 * yn
    y = -0.04 * xn + 0.85 * yn + 1.6
  elsif r < 93
    x = 0.20 * xn - 0.26 * yn
    y = 0.23 * xn + 0.22 * yn + 1.6
  else
    x = -0.15 * xn + 0.28 * yn
    y = 0.26 * xn + 0.24 * yn + 0.44
  end
end

image.write(File.join(output_dir, output_file))
