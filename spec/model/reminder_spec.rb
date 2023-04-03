# frozen_string_literal: true

require 'spec_helper'
require 'rails_helper'

RSpec.describe Reminder, :type => :model do
  before do
    @reminder = create(:reminder)
  end

  it 'is valid with valid attributes' do
    expect(@reminder).to be_valid
  end

  context 'when repeat_frequency is not set' do
    before do
        @reminder = Reminder.create(title: 'test', due_date: Time.now + 1.minute)
    end
    it 'sets default repeat_frequency' do
        expect(@reminder.repeat_frequency).to eq('no_repeat')
    end
    it 'is valid' do
        expect(@reminder).to be_valid
    end
  end

  it 'is invalid with blank title' do
    @reminder.title = ''
    expect(@reminder).to be_invalid
  end

  it 'is invalid with nil due_date' do
    @reminder.due_date = nil
    expect(@reminder).to be_invalid
  end
end
