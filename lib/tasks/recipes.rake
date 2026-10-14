require "net/http"

namespace :recipes do

  # Attaches a photo from a URL, usually the source page's og:image:
  #   bin/rails recipes:photo ID=6 URL=https://...
  task photo: :environment do
    recipe = Recipe.find(ENV.fetch('ID'))
    uri = URI(ENV.fetch('URL'))

    response = Net::HTTP.get_response(uri, 'User-Agent' => 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0 Safari/537.36')
    abort "#{uri} returned #{response.code}" unless response.is_a?(Net::HTTPSuccess)

    content_type = response['Content-Type'].to_s.split(';').first
    abort "#{uri} is #{content_type}, not an image" unless content_type&.start_with?('image/')

    extension = { 'image/jpeg' => '.jpg', 'image/png' => '.png', 'image/webp' => '.webp', 'image/avif' => '.avif' }.fetch(content_type) { File.extname(uri.path) }
    filename = "#{recipe.name.parameterize}#{extension}"
    recipe.photo.attach(io: StringIO.new(response.body), filename:, content_type:)
    puts "Attached #{filename} (#{response.body.bytesize / 1024} KB) to ##{recipe.id} #{recipe.name}"
  end

  # Receives one recipe from bin/push-recipe as JSON on stdin and replaces
  # production's instructions, plus its photo when one is sent. The name
  # guards against dev and production ids drifting apart. Prints what it
  # replaced for the caller to keep as a backup.
  task import: :environment do
    payload = JSON.parse($stdin.read)
    recipe = Recipe.find(payload.fetch('id'))
    abort "Name mismatch: production ##{recipe.id} is #{recipe.name.inspect}, not #{payload['name'].inspect}" unless recipe.name == payload['name']

    backup = { instructions: recipe.instructions&.body&.to_html.to_s }
    photo = payload['photo']
    replace_photo = photo && recipe.photo.blob&.checksum != photo['checksum']
    if replace_photo && recipe.photo.attached?
      backup[:photo] = { filename: recipe.photo.filename.to_s, data: Base64.strict_encode64(recipe.photo.download) }
    end
    puts "BACKUP #{backup.to_json}"

    recipe.instructions = payload.fetch('instructions')
    if replace_photo
      recipe.photo.attach(io: StringIO.new(Base64.decode64(photo['data'])), filename: photo['filename'], content_type: photo['content_type'])
    end
    recipe.save!

    puts "Updated ##{recipe.id} #{recipe.name}#{' with photo' if replace_photo}"
  end

end
