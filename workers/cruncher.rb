require 'nokogiri'
require 'active_support/core_ext/hash/conversions'

class Cruncher

  def self.fetch_datapoints(hash)
    coords = hash["kml"]['Document']['Placemark']['Track']['coord']
    whens = hash["kml"]['Document']['Placemark']['Track']['when']
    split_coords = coords.map{|wh| arr = wh.split[0..-2]}
    ret = whens.zip(split_coords)
  end

  def self.process(file)
    xml = IO.read(file)
    hash = Hash.from_xml(Nokogiri.XML(xml).to_s)
    datapoints = fetch_datapoints(hash)
  end



end
