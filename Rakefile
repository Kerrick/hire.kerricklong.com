task default: 'compile'

desc 'Compile all assets (production)'
multitask compile: ['compile:sass'] do
  puts "Compiled all assets using production settings."
end

desc 'Watch all assets to compile on changes (development)'
task :watch do
  WATCHERS = [:sass]
  begin
    threads = []
    WATCHERS.each do |name|
      sleep 0.1 # Because if you fork too fast, STDOUT can look cluttered.
      threads << {name: name,
                  pid: fork { Rake::Task["watch:#{name.to_s}"].invoke }}
    end
    sleep # Block main the process!
  rescue Interrupt
    puts # Because we don't want the ^C cluttering up our messages.
    threads.each do |thread|
      Process.kill('TERM', thread[:pid])
      puts "[#{thread[:name]}] No longer watching for changes"
    end
  end
end

desc 'Compile, then git add, commit, and push to Github Pages'
task :deploy, [:message] do |t, args|
  if args.message.nil? || args.message.empty?
    puts "You haven't written a commit message. Please do so."
    print "Commit message: "
    message = STDIN.gets.chomp
  else
    message = args.message
  end
  Rake::Task['compile'].invoke
  sh 'git add -A .'
  sh "git commit -m '#{message}'"
  sh 'git push origin gh-pages --force'
end

namespace :watch do
  desc 'Watch the only the sass/ directory'
  task :sass do
    Dir.mkdir 'css'  unless Dir.exists? 'css'
    Dir.mkdir 'scss' unless Dir.exists? 'scss'
    on_change_of_folder 'sass' do
      sh 'sass --update sass:css --style expanded --line-numbers --line-comments', verbose: false
    end
  end
end

namespace :compile do
  desc 'Compile the sass/ directory into CSS for production'
  task :sass do
    Dir.mkdir 'css'  unless Dir.exists? 'css'
    Dir.mkdir 'scss' unless Dir.exists? 'scss'
    sh 'sass --update sass:css --style compressed --force', verbose: false
  end
end

def on_change_of_folder(folder, &block)
  require 'listen'
  begin
    callback = Proc.new do |modified, added, removed|
      if [modified, added, removed] == [nil, nil, nil]
        puts "[#{folder}] Watching for changes. Press Ctrl-C to stop."
      else
        puts "[#{folder}] Change detected!"
      end
      if block_given?
        yield modified, added, removed
      else
        puts "[#{folder}] ...But doing nothing."
      end
    end
    callback.call nil, nil, nil
    listener = Listen.to folder
    listener.change &callback
    listener.start
  rescue Interrupt
    listener.stop
    puts "\n[#{folder}] No longer watching for changes."
  end
end

