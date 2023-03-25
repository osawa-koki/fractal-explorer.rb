require 'tomlrb'
require 'rmagick'

config = Tomlrb.load_file('config.toml')

global_config = config['global']
julia_config = config['julia']

width = global_config['width'].to_i
height = global_config['height'].to_i
output_dir = global_config['output_dir']

x_min = julia_config['x_min'].to_f
x_max = julia_config['x_max'].to_f
y_min = julia_config['y_min'].to_f
y_max = julia_config['y_max'].to_f
cx = julia_config['cx'].to_f
cy = julia_config['cy'].to_f
threshold = julia_config['threshold'].to_f
max_iterations = julia_config['max_iterations'].to_i
color = julia_config['color'].to_i
background_color = julia_config['background_color']
output_file = julia_config['output_file']

image = Magick::Image.new(width, height)

x_delta = (x_max - x_min) / width
y_delta = (y_max - y_min) / height
c = { x: cx, y: cy }

# ジュリア集合の描画
(0..width-1).each do |x|
  (0..height-1).each do |y|
    z = { x: x_min + x * x_delta, y: y_min + y * y_delta }
    i = 0
    while i < max_iterations
      z2 = { x: z[:x] * z[:x] - z[:y] * z[:y], y: 2 * z[:x] * z[:y] }
      z[:x] = z2[:x] + c[:x]
      z[:y] = z2[:y] + c[:y]
      break if z[:x] * z[:x] + z[:y] * z[:y] > threshold
      i += 1
    end
    if i == max_iterations
      image.pixel_color(x, y, background_color)
    else
      color_hsl = "hsl(#{color + i * 360 / max_iterations}, 100%, 50%)"
      image.pixel_color(x, y, Magick::Pixel.from_color(color_hsl))
    end
  end
end

image.write(File.join(output_dir, output_file))
