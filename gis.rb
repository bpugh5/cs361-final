#!/usr/bin/env ruby

class Track
  attr_accessor :name, :segments, :json

  def initialize(segments, name='', json)
    @name = name
    @segments = segments
    @json = json
  end

  def get_json
    json.get_json(self)
  end
end

class TrackString
  def get_json(track)
    json = '{"type": "Feature", '

    if track.name != ''
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
        if track_segment_json != ''
          track_segment_json += ','
        end

        track_segment_json += "[#{coordinate.lon},#{coordinate.lat}"

        if coordinate.ele != nil
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

  def initialize(lon, lat, ele=nil)
    @lon = lon
    @lat = lat
    @ele = ele
  end

end

class Waypoint
attr_accessor :lat, :lon, :ele, :name, :type, :json

  # ele, name, and type are given contextually invalid default values
  def initialize(lon, lat, ele=100000, name='', type='', json)
    @lat = lat
    @lon = lon
    @ele = ele
    @name = name
    @type = type
    @json = json
  end

  def get_json
    json.get_json(self)
  end
end

class WaypointString
  def get_json(waypoint)
    json = '{"type": "Feature","geometry": {"type": "Point","coordinates": '
    json += "[#{waypoint.lon},#{waypoint.lat}"

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

  def to_geojson(indent=0)
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

def main()
  json = WaypointString.new
  w = Waypoint.new(-121.5, 45.5, 30, "home", "flag", json)
  w2 = Waypoint.new(-121.5, 45.6, 100000, "store", "dot", json)
  
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

  t = Track.new([track_segment1, track_segment2], "track 1", json)
  t2 = Track.new([track_segment3], "track 2", json)

  world = World.new("My Data", [w, w2, t, t2])

  puts world.to_geojson()
end

if File.identical?(__FILE__, $0)
  main()
end

