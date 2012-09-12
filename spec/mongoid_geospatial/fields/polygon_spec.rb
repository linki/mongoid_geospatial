require "spec_helper"

describe Mongoid::Geospatial::Polygon do

  describe "(de)mongoize" do

    it "should support a field mapped as polygon" do
      farm = Farm.new(area: [[5,5],[6,5],[6,6],[5,6]])
      farm.area.should eq([[5,5],[6,5],[6,6],[5,6]])
      farm.area.should be_a Mongoid::Geospatial::Polygon
    end

    it "should store as array on mongo" do
      Farm.create(area: [[5,5],[6,5],[6,6],[5,6]])
      Farm.first.area.should eq([[5,5],[6,5],[6,6],[5,6]])
    end

    describe "with rgeo" do
      # farm.area.should be_a RGeo::Geographic::SphericalPolygonImpl
    end

    context ":box, :polygon" do
      before do
        Farm.create_indexes
      end

      let!(:ranch) do
        Farm.create(:name => 'Ranch', area: [[1, 1],[3, 3]], :geom => [2, 2])
      end

      let!(:farm) do
        Farm.create(name: 'Farm', area: [[47, 1],[49, 1.5],[49, 3],[46, 5]], geom: [47.5, 2.26])
      end

      it "returns the documents within a box" do
        Farm.where(:geom.within_box => ranch.area ).to_a.should == [ ranch ]
      end

      it "returns the documents within a polygon" do
        Farm.where(:geom.within_polygon => farm.area).to_a.should == [ farm ]
      end

      it "returns the documents within a center" do
        Farm.where(:geom.within_circle => [ranch.geom, 0.4]).first.should eq(ranch)
      end

      it "returns the documents within a center_sphere" do
        Farm.where(:geom.within_spherical_circle => [ranch.geom, 0.1]).first.should eq(ranch)
      end

    end

  end

end