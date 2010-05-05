# DOCUMATIC TUTORIAL
#   -- Modified spreadsheet example by Zachris

# This tutorial is a trivial demonstration of how Documatic works.  By
# all means play with this file: fiddle with the data, see what
# happens.


require 'rubygems'
require 'documatic'
gem 'documatic', '>= 0.2.1'
# Let's make a trivial table. And include numeric data that should be summarized in the output_file using a FORMULA. 

data = Ruport::Data::Table.new( :column_names => %w(Name Phone Num),
                                :data =>
                                [
                                 ['Madchili Restaurant', '(02) 9805 1287', 10],
                                 ['Shiraz Restaurant', '(02) 9858 2004', 5],
                                 ['The Ranch Bistro Grill', '(02) 9887 2411', 7],
                                ])

data.to_ods_template(:template_file => 'template.ods',
                     :output_file   => 'output/spreadsheet.ods',
					 :options=>"Number")

