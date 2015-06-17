# guard 'rspec', cmd: '--drb --format Fuubar --color' do
guard 'rspec', cmd: 'bundle exec rspec --format documentation --order rand' do
  watch(%r{spec/.+_spec\.rb$})
  watch(%r{^lib/.+\.rb$}) { 'spec' }
  watch('spec/spec_helper.rb') { 'spec' }
end
