# DOCUMATIC TUTORIAL
#   -- by Dave Nelson <urbanus@240gl.org>

# This tutorial is a trivial demonstration of how Documatic works.  By
# all means play with this file: fiddle with the data, see what
# happens.

require '../lib/documatic'

Options = Struct.new(:template_file, :output_file)
opts = Options.new
opts.template_file = 'template.odt'
opts.output_file   = 'output/tested.odt'
text = 'Text-from-Ruby'
Documatic::OpenDocumentText::Template::process_template(:options => opts, :data => [text])
