# DOCUMATIC Test

# I want to test my files, not the installed gem, if any!
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__ + '/../../lib/documatic'))

require 'documatic'
puts "$LOAD_PATH=#{$LOAD_PATH}."
Options = Struct.new(:template_file, :output_file)
opts = Options.new
opts.template_file = 'template.odt'
opts.output_file   = 'output/tested.odt'
text = 'Text-from-Ruby'
Documatic::OpenDocumentText::Template::process_template(:options => opts, :data => [text])
