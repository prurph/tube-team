require 'spec_helper'

describe WatchUpdate do
  describe "associations" do
    it{ should belong_to :video }
  end
end
