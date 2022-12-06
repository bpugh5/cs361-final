#!/usr/bin/env ruby

class Track

  def initialize(segments, name = "")
    @name = name
    @segments = segments
  end

  def get_track_json
    json = '{"type": "Feature", '

    if @name != ""
      json += '"properties": {"title": "' + @name + '"},'
    end

    json += '"geometry": {"type": "MultiLineString","coordinates": [' # use type

    @segments.each_with_index do |segment, index| # extract object into code
      if index > 0
        json += ","
      end
      
      json += '['
      track_segment_json = ''
      segment.coordinates.each do |coordinate|
        if track_segment_json != ''
          track_segment_json += ','
        end
        # Add the coordinate
        track_segment_json += '['
        track_segment_json += "#{coordinate.lon},#{coordinate.lat}"
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
attr_reader :lat, :lon, :ele, :name, :type

  def initialize(lon, lat, ele=nil, name=nil, type=nil)
    @lat = lat
    @lon = lon
    @ele = ele
    @name = name
    @type = type
  end

  def get_waypoint_json(indent=0)
    j = '{"type": "Feature",'
    # if name is not nil or type is not nil
    j += '"geometry": {"type": "Point","coordinates": '
    j += "[#{@lon},#{@lat}"
    if ele != nil
      j += ",#{@ele}"
    end
    j += ']},'
    if name != nil or type != nil
      j += '"properties": {'
      if name != nil
        j += '"title": "' + @name + '"'
      end
      if type != nil  # if type is not nil
        if name != nil
          j += ','
        end
        j += '"icon": "' + @type + '"'  # type is the icon
      end
      j += '}'
    end
    j += "}"
    return j
  end
end

class World

  def initialize(name, things)
    @name = name
    @features = things
  end
  
  def add_feature(f)
    @features.append(t)
  end

  def to_geojson(indent=0)
    # Write stuff
    s = '{"type": "FeatureCollection","features": ['
    @features.each_with_index do |f,i|
      if i != 0
        s +=","
      end
        if f.class == Track
            s += f.get_track_json
        elsif f.class == Waypoint
            s += f.get_waypoint_json
      end
    end
    s + "]}"
  end
end

def main()
  w = Waypoint.new(-121.5, 45.5, 30, "home", "flag")
  w2 = Waypoint.new(-121.5, 45.6, nil, "store", "dot")
  ts1 = [
  Point.new(-122, 45),
  Point.new(-122, 46),
  Point.new(-121, 46),
  ]

  ts2 = [ Point.new(-121, 45), Point.new(-121, 46), ]

  ts3 = [
    Point.new(-121, 45.5),
    Point.new(-122, 45.5),
  ]

  track_segment1 = TrackSegment.new(ts1)
  track_segment2 = TrackSegment.new(ts2)
  track_segment3 = TrackSegment.new(ts3)

  t = Track.new([track_segment1, track_segment2], "track 1")
  t2 = Track.new([track_segment3], "track 2")

  world = World.new("My Data", [w, w2, t, t2])

  puts world.to_geojson()
end

if File.identical?(__FILE__, $0)
  main()
end

