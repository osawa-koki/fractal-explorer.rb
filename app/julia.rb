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
max_iter = julia_config['max_iter'].to_i
internal_color = julia_config['internal_color']
external_color = julia_config['external_color']
output_file = julia_config['output_file']

image = Magick::Image.new(width, height)

# ジュリア集合の描画
for y in 0..height-1 do
  for x in 0..width-1 do
    zx = x_min + (x_max - x_min) * x / width
    zy = y_min + (y_max - y_min) * y / height
    i = 0
    while zx * zx + zy * zy < 4 && i < max_iter do
      tmp = zx * zx - zy * zy + cx
      zy = 2 * zx * zy + cy
      zx = tmp
      i += 1
    end
    if i == max_iter then
      image.pixel_color(x, y, external_color)
    else
      image.pixel_color(x, y, internal_color)
    end
  end
end

image.write(File.join(output_dir, output_file))
