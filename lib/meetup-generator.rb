require 'json'
require 'yaml'

# Everything needed for a meetup generator
#
class MeetupGenerator
  attr_reader :words, :lib, :unused_templates

  def initialize
    grep, dict = find_unix_stuff
    @words = `#{grep} "^[a-z]*$" #{dict}`.split("\n")
    @lib = YAML.load_file(ROOT + 'lib' + 'all_the_things.yaml')
  end

  def find_unix_stuff
    case RUBY_PLATFORM
    when /solaris/
      %w[/bin/grep /usr/share/lib/dict/words]
    when /linux/
      %w[/bin/grep /usr/share/dict/words]
    when /darwin/
      %w[/usr/bin/grep /usr/share/dict/words]
    else
      abort "unsupported platform: #{RUBY_PLATFORM}"
    end
  end

  def title
    @unused_templates ||= lib[:template].dup
    t = unused_templates.sample
    unused_templates.delete(t)
    t.scan(/%\w+%/).each { |k| t = t.sub(k, lib[k[1..-2].to_sym].sample) }
    t.scan(/RAND\d+/).each do |i|
      t = t.sub(i, rand(2..(i.sub(/RAND/, '').to_i)).to_s)
    end
    t
  end

  def talks(count = 5)
    @unused_templates = lib[:template].dup
    count.times.with_object([]) { |_i, a| a.<< title }
  end

  def talker
    lib[:first_name].sample + ' ' + lib[:last_name].sample
  end

  def role
    lib[:job_role].sample + ' ' + lib[:job_title].sample
  end

  def company
    words.sample.sub(/([^aeiou])er$/, '\\1r').downcase + '.io'
  end

  def refreshment
    lib[:food_style].sample + ' ' + lib[:food].sample
  end

  def talk
    { talk: talks(1)[0], talker: talker, role: role, company: company }
  end
end