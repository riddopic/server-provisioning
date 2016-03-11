# encoding: UTF-8

require 'spec_helper'

describe Chef::Exceptions::AttributeNotFound do
  subject { described_class.new("node['server-provisioning']") }
  describe '#new' do
    it 'is a Runtime error that accepts an attribute' do
      expect(subject).to be_a RuntimeError
      expect(subject.attr).to eql("node['server-provisioning']")
    end
  end

  describe '#to_s' do
    let(:output) { "Attribute 'node['server-provisioning']' not found" }

    it 'prints out a message pointing to the missing attribute' do
      expect(subject.to_s).to eql(output)
    end
  end
end
