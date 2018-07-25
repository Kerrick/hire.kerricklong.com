task default: 'compile'

desc 'Compile all assets (production)'
multitask compile: ['resume.txt'] do
  puts "Compiled all assets using production settings."
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

namespace :compile do
  desc 'Compile index.html to plain text as resume.txt'
  file 'resume.txt' => 'index.html' do |t|
    txt = `lynx -nonumbers -nolist -dump index.html -raw -display_charset=US-ASCII`
    txt.gsub! /\n\s+?\* View.+$/, ''
    File.open 'resume.txt', 'w' do |f|
      f.write txt
    end
  end
end
