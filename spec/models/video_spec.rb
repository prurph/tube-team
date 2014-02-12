require 'spec_helper'

describe Video do
  describe "validations" do
    it { should validate_presence_of :yt_id }
    it { should validate_uniqueness_of :yt_id }
  end

  describe "associations" do
    it { should belong_to :team }
    it { should have_one(:user) }
    it { should have_many(:watch_updates).dependent(:destroy) }
  end
end
