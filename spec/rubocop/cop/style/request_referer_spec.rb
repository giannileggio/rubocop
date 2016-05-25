# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'
require 'pry'

describe RuboCop::Cop::Style::RequestReferer do
  subject(:cop) { described_class.new }

  before { inspect_source(cop, 'puts request.referrer') }

  it 'registers an offense for request.referrer' do
    expect(cop.offenses.size).to eq(1)
  end

  it 'highlights the offence' do
    expect(cop.highlights).to eq(['request.referrer'])
  end

  it 'sends a message to the user' do
    expect(cop.messages)
      .to eq(['Use `request.referer` instead of `request.referrer`'])
  end
end
