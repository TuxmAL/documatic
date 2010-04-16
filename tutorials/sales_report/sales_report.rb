#!/usr/bin/ruby

require 'rubygems'
require 'documatic'

include Ruport::Data

# Some made-up data.
table = Table.new( :column_names => %w(Region Department Product Amount),
                   :data => [
                             ['Northern', 'Electrical', 'TV', 300],
                             ['Eastern',  'Furniture', 'Chair', 75],
                             ['Western',  'Furniture', 'Table', 150],
                             ['Western',  'Electrical', 'Stereo', 100],
                             ['Eastern',  'Kitchen', 'Plates', 30],
                             ['Eastern',  'Kitchen', 'Mugs', 5],
                             ['Northern', 'Furniture', 'Table', 200],
                             ['Northern', 'Electrical', 'MP3', 50],
                             ['Western',  'Kitchen', 'Spoons', 10],
                             ['Western',  'Furniture', 'Sofa', 750],
                             ['Western',  'Furniture', 'Lamp', 40],
                             ['Western',  'Furniture', 'Cupboard', 400]
                            ] )
data = Grouping.new( table, :by => %w(Region Department) )

# Groupings don't have a sigma method, so we'll calculate the grand
# total here.
grand_total = data.inject(0) do |sum, (group_name, group)|
  sum + group.sigma('Amount')
end

# :template and :output are mandatory; :methinks is not (it just
# demonstrates that you can pass in whatever you want).
# s/kick/sux/ if you feel unkind.  :)
data.to_odt_template( :template_file    => 'sales_report.odt',
                      :output_file      => 'output/sales_report.odt',
                      :grand_total      => grand_total,
                      :methinks         => 'Ruport and Documatic kick ass!' )
