#!/usr/bin/env ruby

class Track
  attr_accessor :name, :segments, :json

  def initialize(args)    
    @segments = args[:segments]
    @name = args[:name] || ''
    @json = args[:json]
  end

  def get_json
    json.get_json(self)
  end

end

class TrackString
  def get_json(track)
    json = '{"type": "Feature", '

    if !track.name.empty?
      json += '"properties": {"title": "' + track.name + '"},'
    end

    json += '"geometry": {"type": "MultiLineString","coordinates": ['

    track.segments.each_with_index do |segment, index|
      if index > 0
        json += ","
      end
      
      json += '['

      track_segment_json = ''

      segment.coordinates.each do |coordinate|
        if !track_segment_json.empty?
          track_segment_json += ','
        end

        track_segment_json += "[#{coordinate.lon},#{coordinate.lat}"

        if coordinate.ele != 100000
          track_segment_json += ",#{coordinate.ele}"
        end

        track_segment_json += ']'
      end
      json += track_segment_json
      json += ']'
    end
    json + ']}}'
  end

end

class TrackSegment
  attr_reader :coordinates

  def initialize(coordinates)
    @coordinates = coordinates
  end

end

class Point
  attr_reader :lat, :lon, :ele

  def initialize(lon, lat, ele=100000)
    @lon = lon
    @lat = lat
    @ele = ele
  end

end

class Waypoint
  attr_accessor :lat, :lon, :ele, :name, :type, :json

  # ele, name, and type are given contextually invalid default values
  def initialize(args)
    @lat = args[:lat]
    @lon = args[:lon]
    @ele = args[:ele] || 100000
    @name = args[:name] || ''
    @type = args[:type] || ''
    @json = args[:json]
  end

  def get_json
    json.get_json(self)
  end

end

class WaypointString
  def get_json(waypoint)
    json = '{"type": "Feature","geometry": {"type": "Point","coordinates": '
    json += "[#{waypoint.lat},#{waypoint.lon}"

    if waypoint.ele != 100000
      json += ",#{waypoint.ele}"
    end

    json += ']},'

    if !waypoint.name.empty? or !waypoint.type.empty?
      json += '"properties": {'

      if !waypoint.name.empty?
        json += '"title": "' + waypoint.name + '"'
      end

      if !waypoint.type.empty?

        if !waypoint.name.empty?
          json += ','
        end

        json += '"icon": "' + waypoint.type + '"' 
      end
      json += '}'
    end
    json += "}"
  end

end

class World

  def initialize(name, features)
    @name = name
    @features = features
  end
  
  def add_feature(feature)
    @features.append(type)
  end

  def to_geojson
    string = '{"type": "FeatureCollection","features": ['

    @features.each_with_index do |feature, index|
      if index != 0
        string +=","
      end
      string += feature.get_json
    end
    string + "]}"
  end

end

def main
  json = WaypointString.new
  w = Waypoint.new(:lat => -121.5, :lon => 45.5, :ele => 30, :name => "home", :type => "flag", :json => json)
  w2 = Waypoint.new(:lat => -121.5, :lon => 45.6, :ele => 100000, :name => "store", :type => "dot", :json => json)
  
  ts1 = [
  Point.new(-122, 45),
  Point.new(-122, 46),
  Point.new(-121, 46),
  ]

  ts2 = [ 
    Point.new(-121, 45), 
    Point.new(-121, 46), 
  ]

  ts3 = [
    Point.new(-121, 45.5),
    Point.new(-122, 45.5),
  ]

  track_segment1 = TrackSegment.new(ts1)
  track_segment2 = TrackSegment.new(ts2)
  track_segment3 = TrackSegment.new(ts3)
  json = TrackString.new

  t = Track.new(:segments => [track_segment1, track_segment2], :name => "track 1", :json => json)
  t2 = Track.new(:segments => [track_segment3], :name => "track 2", :json => json)

  world = World.new("My Data", [w, w2, t, t2])

  puts world.to_geojson
end

if File.identical?(__FILE__, $0)
  main
end
