Pod::Spec.new do |s|
	s.name     = 'DDCli'
	s.version  = '1.0'
	s.license  = ''
	s.summary  = 'A framework for building command line based Objective-C tools (utils only!).'
	s.homepage = 'http://www.dribin.org/dave/software/#ddcli'
	s.author   = { 'Dave Dribin' => 'dave@dribin.org' }
	s.source   = { :hg => 'http://www.dribin.org/dave/hg/ddcli' }
	s.source_files = 'lib/DDCliUtil.*'
end
