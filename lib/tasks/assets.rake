# https://stackoverflow.com/a/30344992/418864
Rake::Task['assets:precompile'].clear
  namespace :assets do
    task 'precompile' do
    puts 'SKIPPING rake assets:precompile'
  end
end