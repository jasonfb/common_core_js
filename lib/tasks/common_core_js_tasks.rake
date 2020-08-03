namespace :common_core do
  desc "install"

  task install: :environment  do
    puts "please run rails generate common_core:install"
  end
end
