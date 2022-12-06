require_relative 'gis.rb'
require 'json'
require 'test/unit'

class TestGis < Test::Unit::TestCase

  def test_waypoints
    json = WaypointString.new
    w = Waypoint.new(-121.5, 45.5, 30, "home", "flag", json)
    expected = JSON.parse('{"type": "Feature","properties": {"title": "home","icon": "flag"},"geometry": {"type": "Point","coordinates": [-121.5,45.5,30]}}')
    result = JSON.parse(w.get_json)
    assert_equal(result, expected)

    w = Waypoint.new(-121.5, 45.5, 100000, '', "flag", json)
    expected = JSON.parse('{"type": "Feature","properties": {"icon": "flag"},"geometry": {"type": "Point","coordinates": [-121.5,45.5]}}')
    result = JSON.parse(w.get_json)
    assert_equal(result, expected)

    w = Waypoint.new(-121.5, 45.5, 100000, "store", '', json)
    expected = JSON.parse('{"type": "Feature","properties": {"title": "store"},"geometry": {"type": "Point","coordinates": [-121.5,45.5]}}')
    result = JSON.parse(w.get_json)
    assert_equal(result, expected)
  end

  def test_tracks
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
    json = TrackString.new

    t = Track.new([track_segment1, track_segment2], "track 1", json)
    expected = JSON.parse('{"type": "Feature", "properties": {"title": "track 1"},"geometry": {"type": "MultiLineString","coordinates": [[[-122,45],[-122,46],[-121,46]],[[-121,45],[-121,46]]]}}')
    result = JSON.parse(t.get_json)
    assert_equal(expected, result)

    t = Track.new([track_segment3], "track 2", json)
    expected = JSON.parse('{"type": "Feature", "properties": {"title": "track 2"},"geometry": {"type": "MultiLineString","coordinates": [[[-121,45.5],[-122,45.5]]]}}')
    result = JSON.parse(t.get_json)
    assert_equal(expected, result)
  end

  def test_world
    json = WaypointString.new
    w = Waypoint.new(-121.5, 45.5, 30, "home", "flag", json)
    w2 = Waypoint.new(-121.5, 45.6, 100000, "store", "dot", json)
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
    json = TrackString.new

    t = Track.new([track_segment1, track_segment2], "track 1", json)
    t2 = Track.new([track_segment3], "track 2", json)

    w = World.new("My Data", [w, w2, t, t2])

    expected = JSON.parse('{"type": "FeatureCollection","features": [{"type": "Feature","properties": {"title": "home","icon": "flag"},"geometry": {"type": "Point","coordinates": [-121.5,45.5,30]}},{"type": "Feature","properties": {"title": "store","icon": "dot"},"geometry": {"type": "Point","coordinates": [-121.5,45.6]}},{"type": "Feature", "properties": {"title": "track 1"},"geometry": {"type": "MultiLineString","coordinates": [[[-122,45],[-122,46],[-121,46]],[[-121,45],[-121,46]]]}},{"type": "Feature", "properties": {"title": "track 2"},"geometry": {"type": "MultiLineString","coordinates": [[[-121,45.5],[-122,45.5]]]}}]}')
    result = JSON.parse(w.to_geojson)
    assert_equal(expected, result)
  end

end
