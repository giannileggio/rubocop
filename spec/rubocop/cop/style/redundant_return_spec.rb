# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::RedundantReturn, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) { { 'AllowMultipleReturnValues' => false } }

  it 'reports an offense for def with only a return' do
    src = ['def func',
           '  return something',
           'end']
    inspect_source(cop, src)
    expect(cop.offenses.size).to eq(1)
  end

  it 'reports an offense for defs with only a return' do
    src = ['def Test.func',
           '  return something',
           'end']
    inspect_source(cop, src)
    expect(cop.offenses.size).to eq(1)
  end

  it 'reports an offense for def ending with return' do
    src = ['def func',
           '  one',
           '  two',
           '  return something',
           'end']
    inspect_source(cop, src)
    expect(cop.offenses.size).to eq(1)
  end

  it 'reports an offense for defs ending with return' do
    src = ['def func',
           '  one',
           '  two',
           '  return something',
           'end']
    inspect_source(cop, src)
    expect(cop.offenses.size).to eq(1)
  end

  it 'accepts return in a non-final position' do
    src = ['def func',
           '  return something if something_else',
           'end']
    inspect_source(cop, src)
    expect(cop.offenses).to be_empty
  end

  it 'does not blow up on empty method body' do
    src = ['def func',
           'end']
    inspect_source(cop, src)
    expect(cop.offenses).to be_empty
  end

  it 'auto-corrects by removing redundant returns' do
    src = ['def func',
           '  one',
           '  two',
           '  return something',
           'end'].join("\n")
    result_src = ['def func',
                  '  one',
                  '  two',
                  '  something',
                  'end'].join("\n")
    new_source = autocorrect_source(cop, src)
    expect(new_source).to eq(result_src)
  end

  context 'when return has no arguments' do
    shared_examples 'common behavior' do |ret|
      let(:src) do
        ['def func',
         '  one',
         '  two',
         "  #{ret}",
         '  # comment',
         'end']
      end

      it "registers an offense for #{ret}" do
        inspect_source(cop, src)
        expect(cop.offenses.size).to eq(1)
      end

      it "auto-corrects by replacing #{ret} with nil" do
        new_source = autocorrect_source(cop, src)
        expect(new_source).to eq(['def func',
                                  '  one',
                                  '  two',
                                  '  nil',
                                  '  # comment',
                                  'end'].join("\n"))
      end
    end

    it_behaves_like 'common behavior', 'return'
    it_behaves_like 'common behavior', 'return()'
  end

  context 'when multi-value returns are not allowed' do
    it 'reports an offense for def with only a return' do
      src = ['def func',
             '  return something, test',
             'end']
      inspect_source(cop, src)
      expect(cop.offenses.size).to eq(1)
    end

    it 'reports an offense for defs with only a return' do
      src = ['def Test.func',
             '  return something, test',
             'end']
      inspect_source(cop, src)
      expect(cop.offenses.size).to eq(1)
    end

    it 'reports an offense for def ending with return' do
      src = ['def func',
             '  one',
             '  two',
             '  return something, test',
             'end']
      inspect_source(cop, src)
      expect(cop.offenses.size).to eq(1)
    end

    it 'reports an offense for defs ending with return' do
      src = ['def func',
             '  one',
             '  two',
             '  return something, test',
             'end']
      inspect_source(cop, src)
      expect(cop.offenses.size).to eq(1)
    end

    it 'auto-corrects by making implicit arrays explicit' do
      src = ['def func',
             '  return  1, 2',
             'end'].join("\n")
      result_src = ['def func',
                    '  [1, 2]', # Just 1, 2 is not valid Ruby.
                    'end'].join("\n")
      new_source = autocorrect_source(cop, src)
      expect(new_source).to eq(result_src)
    end

    it 'auto-corrects removes return when using an explicit hash' do
      src = ['def func',
             '  return {:a => 1, :b => 2}',
             'end'].join("\n")
      result_src = ['def func',
                    '  {:a => 1, :b => 2}', # :a => 1, :b => 2 is not valid Ruby
                    'end'].join("\n")
      new_source = autocorrect_source(cop, src)
      expect(new_source).to eq(result_src)
    end

    it 'auto-corrects by making an implicit hash explicit' do
      src = ['def func',
             '  return :a => 1, :b => 2',
             'end'].join("\n")
      result_src = ['def func',
                    '  {:a => 1, :b => 2}', # :a => 1, :b => 2 is not valid Ruby
                    'end'].join("\n")
      new_source = autocorrect_source(cop, src)
      expect(new_source).to eq(result_src)
    end
  end

  context 'when multi-value returns are allowed' do
    let(:cop_config) { { 'AllowMultipleReturnValues' => true } }

    it 'accepts def with only a return' do
      src = ['def func',
             '  return something, test',
             'end']
      inspect_source(cop, src)
      expect(cop.offenses).to be_empty
    end

    it 'accepts defs with only a return' do
      src = ['def Test.func',
             '  return something, test',
             'end']
      inspect_source(cop, src)
      expect(cop.offenses).to be_empty
    end

    it 'accepts def ending with return' do
      src = ['def func',
             '  one',
             '  two',
             '  return something, test',
             'end']
      inspect_source(cop, src)
      expect(cop.offenses).to be_empty
    end

    it 'accepts defs ending with return' do
      src = ['def func',
             '  one',
             '  two',
             '  return something, test',
             'end']
      inspect_source(cop, src)
      expect(cop.offenses).to be_empty
    end

    it 'does not auto-correct' do
      src = ['def func',
             '  return  1, 2',
             'end'].join("\n")
      new_source = autocorrect_source(cop, src)
      expect(new_source).to eq(src)
    end
  end
end
