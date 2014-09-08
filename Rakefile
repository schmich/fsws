require 'fileutils'

class GemInfo
  def initialize
    @gemspec_filename = Dir['*.gemspec'].first
  end
   
  def spec
    @spec ||= eval(File.read(@gemspec_filename))
  end

  def name
    @name ||= spec.name
  end

  def version
    @version ||= spec.version.to_s
  end

  def gem_filename
    "#{name}-#{version}.gem"
  end

  def gemspec_filename
    @gemspec_filename
  end
end

$gem = GemInfo.new

desc "Start irb #{$gem.name} session"
task :irb do
  sh "irb -rubygems -I./lib -r ./lib/#{$gem.name.gsub('-', '/')}.rb"
end

desc "Install #{$gem.name} gem"
task :'gem:install' => :'gem:build' do
  gemfile = "gem/#{$gem.gem_filename}"
  if !gemfile.nil?
    sh "gem install --no-ri --no-rdoc #{gemfile}"
  else
    puts 'Could not find gem.'
  end
end

desc "Uninstall #{$gem.name} gem"
task :'gem:uninstall' do
  sh "gem uninstall #{$gem.name} -x"
end

desc "Build #{$gem.name} gem"
task :'gem:build' do
  FileUtils.mkdir_p('gem')
  sh "gem build #{$gem.gemspec_filename}"
  FileUtils.mv $gem.gem_filename, 'gem'
end

desc "Release #{$gem.name} v#{$gem.version} and tag in git"
task :'gem:release' => [:not_root, :'gem:build'] do
  if (`git` rescue nil).nil?
    abort 'Could not run git command.'
  end

  if (`gem` rescue nil).nil?
    abort 'Could not run gem command.'
  end

  unless `git branch --no-color`.strip =~ /^\*\s+master$/
    abort 'You must release from the master branch.'
  end

  unless `git status` =~ /^nothing to commit/m
    abort 'You cannot release with outstanding changes (see git status).'
  end

  version = $gem.version
  tag = "v#{version}"

  if `git tag`.strip =~ /^#{tag}$/
    abort "Tag #{tag} already exists, you must bump version in version.rb."
  end

  puts "Releasing version #{version}."

  sh "git commit --allow-empty -a -m \"Release #{version}.\""
  sh "git tag #{tag}"
  sh 'git push origin master'
  sh "git push origin #{tag}"
  sh "gem push gem/#{$gem.gem_filename}"

  puts 'Fin.'
end

task :not_root do
  if !(`whoami` rescue nil).nil?
    if `whoami`.strip == 'root'
      abort 'Do not run as root.'
    end
  end
end
