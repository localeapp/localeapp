require "spec_helper"

module Localeapp
  RSpec.describe Formats do
    let(:formats) { Object.new.extend Formats }

    describe "#path_suffix_for_format" do
      it "returns '.json' when given :json" do
        expect(formats.path_suffix_for_format :json).to eq '.json'
      end

      it "returns '.yml' when given :yaml" do
        expect(formats.path_suffix_for_format :yaml).to eq '.yml'
      end

      it "raises an error when given format is unknown" do
        expect { formats.path_suffix_for_format :foo }
          .to raise_error InvalidFormatError
      end
    end
  end
end
