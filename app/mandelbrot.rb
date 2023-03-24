require 'tomlrb'
require 'rmagick'

config = Tomlrb.load_file('config.toml')

global_config = config['global']
mandelbrot_config = config['mandelbrot']

width = global_config['width'].to_i
height = global_config['height'].to_i
output_dir = global_config['output_dir']

x_min = mandelbrot_config['x_min'].to_f
x_max = mandelbrot_config['x_max'].to_f
y_min = mandelbrot_config['y_min'].to_f
y_max = mandelbrot_config['y_max'].to_f
max_iterations = mandelbrot_config['max_iterations'].to_i
internal_color = mandelbrot_config['internal_color']
external_color = mandelbrot_config['external_color']
output_file = mandelbrot_config['output_file']

image = Magick::Image.new(width, height)

# マンデルブロ集合の描画
for y in 0..height-1
  for x in 0..width-1
    c_re = (x.to_f / width.to_f) * (x_max - x_min) + x_min
    c_im = (y.to_f / height.to_f) * (y_max - y_min) + y_min
    z_re = c_re
    z_im = c_im
    is_inside = true
    for i in 0..max_iterations-1
      z_re2 = z_re * z_re
      z_im2 = z_im * z_im
      if z_re2 + z_im2 > 4
        is_inside = false
        break
      end
      z_im = 2 * z_re * z_im + c_im
      z_re = z_re2 - z_im2 + c_re
    end
    if is_inside
      image.pixel_color(x, y, internal_color)
    else
      image.pixel_color(x, y, external_color)
    end
  end
end


image.write(File.join(output_dir, output_file))
