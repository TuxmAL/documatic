# DOCUMATIC TUTORIAL
#   -- by Dave Nelson <urbanus@240gl.org>

# This tutorial is a trivial demonstration of how Documatic works.  By
# all means play with this file: fiddle with the data, see what
# happens.

# We start by requiring the 'documatic' rubygem, which also loads
# Ruport.

require 'rubygems'
require 'documatic'

# Let's make a trivial table.

data = Ruport::Data::Table.new( :column_names => %w(Name Phone),
                                :data =>
                                [
                                 ['Madchili Restaurant', '(02) 9805 1287'],
                                 ['Shiraz Restaurant', '(02) 9858 2004'],
                                 ['The Ranch Bistro Grill', '(02) 9887 2411'],
                                ])

# Now let's generate an OpenDocument text file using Documatic.
# (Note: the output directory will be created if it does not exist
# yet.  If the output file already exists it will be overwritten.)

data.to_odt_template(:template_file => 'template.odt',
                     :output_file   => 'output/tutorial.odt')

# Now you will want to look at both the original template and the
# output file.  They should be fairly self-explanatory, but if you
# have any questions please drop by the mailing list:
#
#    http://groups.google.com/group/ruby-reports
