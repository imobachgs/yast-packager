#! /usr/bin/env rspec

require_relative "../test_helper"
require "y2packager/pkg_helpers"

describe Y2Packager::PkgHelpers do
  subject(:pkg_helpers) { Y2Packager::PkgHelpers }

  describe ".source_create" do
    let(:url) { "http://download.opensuse.org/$releasever/repo/oss/" }
    let(:expanded_url) { "http://download.opensuse.org/tumbleweed/repo/oss/" }
    let(:src_id) { 1 }

    before do
      allow(Yast::Pkg).to receive(:ExpandedUrl).with(url).and_return(expanded_url)
      allow(Yast::Pkg).to receive(:SourceCreate).and_return(src_id)
    end

    it "registers the repository using the expanded URL" do
      expect(Yast::Pkg).to receive(:SourceCreate).with(expanded_url, "/")
        .and_return(src_id)
      subject.source_create(url, "/")
    end

    it "adjusts the repository URL to use the original one" do
      expect(Yast::Pkg).to receive(:SourceChangeUrl).with(src_id, url)
      subject.source_create(url, "/")
    end

    it "returns the repository id" do
      expect(subject.source_create(url, "/")).to eq(src_id)
    end

    context "when adding the repository fails with -1" do
      let(:src_id) { -1 }

      it "returns -1" do
        expect(subject.source_create(url, "/")).to eq(-1)
      end

      it "does not try to adjust the URL" do
        expect(Yast::Pkg).to_not receive(:SourceChangeUrl)
        subject.source_create(url, "/")
      end
    end

    context "when adding the repository fails with nil" do
      let(:src_id) { nil }

      it "returns nil" do
        expect(subject.source_create(url, "/")).to be_nil
      end

      it "does not try to adjust the URL" do
        expect(Yast::Pkg).to_not receive(:SourceChangeUrl)
        subject.source_create(url, "/")
      end
    end
  end
end
