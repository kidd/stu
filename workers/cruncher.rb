require 'nokogiri'
require 'active_support/core_ext/hash/conversions'

class Cruncher
  def self.process(file)
    xml = IO.read(file)
    hash = Hash.from_xml(Nokogiri.XML(xml).to_s)
  end
end
