require 'spec_helper'

describe "Race Model" do
  let(:race) { Race.new }
  it 'can be created' do
    race.should_not be_nil
  end
end
