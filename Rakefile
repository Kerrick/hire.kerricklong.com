task default: 'compile'

desc 'Compile all assets (production)'
multitask compile: ['resume.txt'] do
  puts "Compiled all assets using production settings."
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
