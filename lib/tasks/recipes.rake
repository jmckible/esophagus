namespace :recipes do

  # Receives one recipe's instructions from bin/push-recipe and replaces
  # production's copy. NAME guards against dev and production ids drifting
  # apart. Prints the old body for the caller to keep as a backup.
  task import: :environment do
    recipe = Recipe.find(ENV.fetch('ID'))
    name = Base64.decode64(ENV.fetch('NAME')).force_encoding('UTF-8')
    abort "Name mismatch: production ##{recipe.id} is #{recipe.name.inspect}, not #{name.inspect}" unless recipe.name == name

    puts "BACKUP #{Base64.strict_encode64(recipe.instructions&.body&.to_html.to_s)}"
    recipe.update!(instructions: Base64.decode64(ENV.fetch('INSTRUCTIONS')).force_encoding('UTF-8'))
    puts "Updated ##{recipe.id} #{recipe.name}"
  end

end
