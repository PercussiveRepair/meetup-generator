require_relative 'version'

def gem_version
  format('%s.%s', BASE_VERSION, build_number)
end

def build_number
  ENV['TRAVIS_BUILD_NUMBER'] || 0
end
