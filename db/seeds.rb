cookbook = Cookbook.where(name: 'Lindsey & Jordan').first_or_create

lindsey = cookbook.users.where( email: 'thor.lindsey@gmail.com').first_or_create(first_name: 'Lindsey', last_name: 'Thordarson', password: 'password1234', password_confirmation: 'password1234')
jordan  = cookbook.users.where( email: 'jordan@mckible.com').first_or_create(first_name: 'Jordan', last_name: 'McKible', password: 'password1234', password_confirmation: 'password1234')
