require 'rubygems'
require 'xmlsimple'
require 'documatic'

# Some abbrevs
ODT = Documatic::OpenDocumentText::Template
RCO = Ruport::Controller::Options

# This example demonstrates how multiple sets of data -- including
# non-Ruport data -- can be sent to Documatic for rendering.  It also
# illustrates the use of partials: reusable sub-templates.  The
# partials are inserted conditionally (i.e. only if the data they are
# supposed to render exists).

# This example makes use of the XmlSimple library (install with `sudo
# gem install xml-simple`).  This converts the XML into a Ruby-like
# data structure with arrays and hashes etc.


# First type of data: some contact details.
contact = {'Name' => 'Joe Bloggs',
  'Address' => '10 Somewhere St',
  'Suburb'  => 'LANE COVE WEST  NSW  2066'}

# Second type of data: some albums.
albums_xml = <<-END
<albums>
  <album>
    <name>OK Computer</name>
    <artist>Radiohead</artist>
    <year>1997</year>
  </album>
  <album>
    <name>Synchronicity</name>
    <artist>The Police</artist>
    <year>1983</year>
  </album>
  <album>
    <name>Tommy</name>
    <artist>The Who</artist>
    <year>1969</year>
  </album>
  <album>
    <name>The Wall</name>
    <artist>Pink Floyd</artist>
    <year>1979</year>
  </album>
</albums>
END
albums = XmlSimple.xml_in(albums_xml)

# Third type of data: some DVDs.
dvds_xml = <<-END
<dvds>
  <dvd type="TV Series" region="1">
    <title>The Shield -- The Complete First Season</title>
    <year>2002</year>
    <stars>
      <star>Michael Chiklis</star>
      <star>Benito Martinez</star>
      <star>Walton Goggins</star>
      <star>Jay Karnes</star>
      <star>CCH Pounder</star>
    </stars>
  </dvd>
  <dvd type="Movie" region="4">
    <title>The Cat in the Hat</title>
    <year>2004</year>
    <stars>
      <star>Mike Myers</star>
      <star>Alec Baldwin</star>
      <star>Kelly Preston</star>
      <star>Dakota Fanning</star>
    </stars>
  </dvd>
  <dvd type="TV Series" region="4">
    <title>Teletubbies -- Animals Big and Small</title>
    <year>2001</year>
    <stars>
      <star>Tinky Winky</star>
      <star>Dipsie</star>
      <star>La La</star>
      <star>Po</star>
      <star>Noo Noo</star>
    </stars>
  </dvd>
</dvds>
END
dvds = XmlSimple.xml_in(dvds_xml)

# Options: the master template and the output path/filename.
options = RCO.new( :template_file => 'multi.odt',
                   :output_file   => 'output/multi.odt' )

# Process the template, passing in the three types of data as above.
ODT.process_template( :options => options,
                      :data => { 'contact' => contact, 'albums' => albums,
                        'dvds' => dvds } )
