require 'spec_helper'

describe User do
  before { @user = User.new(username: "Namesies", email: "user@example.com",
                            password: "foobar55", password_confirmation:
                            "foobar55") }
  subject { @user }

  it { should respond_to(:username) }
  it { should respond_to(:email) }
  it { should respond_to(:encrypted_password) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }

  it { should be_valid }

  describe "when name is missing" do
    before { @user.username = " " }
    it { should_not be_valid }
  end

  describe "when email is missing" do
    before { @user.email = " " }
    it { should_not be_valid }
  end

  describe "when email format is invalid" do
    it "should be invalid" do
      addresses = %w{ meme@gmail,com hihi_at_hihi.org supbro@gmail }
      addresses.each do |invalid_address|
        @user.email = invalid_address
        expect(@user).not_to be_valid
      end
    end
  end

  describe "when email format is valid" do
    it "should be valid" do
      addresses = %w{ psco@tt.com ti_bb-ON@g.a.com al+ex@time.edu }
      addresses.each do |valid_address|
        @user.email = valid_address
        expect(@user).to be_valid
      end
    end
  end
end
