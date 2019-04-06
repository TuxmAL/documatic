# DOCUMATIC Test

require File.join(File.dirname(__FILE__), '../lib/documatic')

Options = Struct.new(:template_file, :output_file)
opts = Options.new
opts.template_file = 'template.odt'
opts.output_file   = 'output/tested.odt'
text = 'Text-from-Ruby'

Documatic::OpenDocumentText::Template::process_template(:options => opts, :data => [text])
