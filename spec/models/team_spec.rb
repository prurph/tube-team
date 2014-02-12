require 'spec_helper'

describe Team do
  describe "associations" do
    it { should belong_to :user }
    it { should have_many(:videos).dependent(:destroy) }
  end

  describe "validations" do
    it { should validate_presence_of :name }
    it { should validate_presence_of :user_id }
    it { should validate_uniqueness_of :name }
    it { should validate_uniqueness_of :user_id }
  end

  describe "#get_rank" do
    before do
      @team  = create(:team, points: 10)
      @team2 = create(:team, points: 25)
      @team3 = create(:team, points: 50)
    end
    it "should return the rank of a team" do
      expect(@team.get_rank).to eq(3)
      expect(@team2.get_rank).to eq(2)
      expect(@team3.get_rank).to eq(1)
      expect(Team.all.count).to eq(3)
    end
  end

  describe '#update_watches' do
    before do
      @team = create(:team)
      @team2 = create(:team)
      @video = create(:video, watches: 10, team: @team)
      @video2 = create(:video, watches: 100, team: @team)
    end

    it "should return the total watches of a team's videos" do
      @team.update_watches
      expect(@team.watches).to eq(110)
      expect(@team2.watches).to eq(0)
    end
  end

  describe '#points_total' do
    before do
      @team = create(:team, points: 10, past_points: 10)
      @team2 = create(:team, points: 100, past_points: 0)
    end

    it "should return the total points of a team" do
      expect(@team.points_total).to eq(20)
      expect(@team2.points_total).to eq(100)
    end
  end

  describe '#update_points' do
    before do
      @team = create(:team, points: 10)
      @video = create(:video, points: 25)
      @video2 = create(:video, points: 50)
    end
  end

  # describe "#update_points" do
  #   before(:all) do
  #     @team8  = Team.create(name: "Team1", user_id: 8, points: 10)
  #     @video3 = Video.new(yt_id: "abc", points: 25)
  #     @video4 = Video.new(yt_id: "bcd", points: 50)
  #     @team8.videos << @video3 << @video4
  #     Video.any_instance.stub(:refresh_watches)
  #     Video.any_instance.stub(:update_points)
  #   end

  #   it "should update team points based on video points" do
  #     @team8.update_points # How to stub inside this block
  #     expect(@team8.points).to eq(75)
  #   end
  # end
end
