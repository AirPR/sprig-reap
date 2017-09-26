require 'spec_helper'

describe Sprig::Reap::Configuration do
  subject { described_class.new }

  before do
    stub_rails_root
  end

  describe "#target_env" do
    context "given a fresh configuration" do
      it "grabs the default" do
        Sprig::Reap::Inputs::Environment.should_receive(:default)

        subject.target_env
      end
    end
  end

  describe "#target_env=" do
    it "parses the input" do
      Sprig::Reap::Inputs::Environment.should_receive(:parse).with(:shaboosh)

      subject.target_env = :shaboosh
    end
  end

  describe "#models" do
    context "given a fresh configuration" do
      it "grabs the default" do
        Sprig::Reap::Inputs::Model.should_receive(:default)

        subject.models
      end
    end
  end

  describe "#models=" do
    it "parses the input" do
      Sprig::Reap::Inputs::Model.should_receive(:parse).with(Post)

      subject.models = Post
    end

    context "when given an array of ActiveRecord::Relations" do
      it "sets the classes" do
        subject.classes = [Comment.where(id: 1)]

        subject.classes.should == [Comment.where(id: 1)]
      end
    end
  end

  describe "#ignored_attrs" do
    context "given a fresh configuration" do
      it "grabs the default" do
        Sprig::Reap::Inputs::IgnoredAttrs.should_receive(:default)

        subject.ignored_attrs
      end
    end
  end

  describe "#ignored_attrs=" do
    it "parses the input" do
      Sprig::Reap::Inputs::IgnoredAttrs.should_receive(:parse).with('boom, shaka, laka')

      subject.ignored_attrs = 'boom, shaka, laka'
    end
  end

  describe "#ignored_dependencies" do
    context "from a fresh configuration" do
      it "it should have no ignored dependencies for a class" do
        subject.ignored_dependencies(Post).should == []
      end
    end
  end

  describe "#ignored_dependencies=" do
    context "when given nil" do
      before { subject.ignored_attrs = nil }

      it "it should have no ignored dependencies for a class" do
        subject.ignored_dependencies(Post).should == []
      end
    end

    context "when given an hash of ignored_dependencies" do
      before do
        subject.ignored_dependencies = {
          post: [:user]
        }
      end

      it "it should have the correct ignored dependencies for a class" do
        subject.ignored_dependencies(Post).should == [:user]
      end
    end

    context "when given a hash with an all key" do
      before do
        subject.ignored_dependencies = {
          all: [:created_by],
          post: [:poster]
        }
      end

      it "should include those dependencies with any class" do
        subject.ignored_dependencies(Post).should == [:poster, :created_by]
      end
    end
  end

  describe "#logger" do
    it "initializes a new logger" do
      Logger.should_receive(:new)

      subject.logger
    end
  end

  describe "#omit_empty_attrs" do
    context "from a fresh configuration" do
      its(:omit_empty_attrs) { should == false }
    end
  end

  describe "#omit_empty_attrs" do
    context "when given nil" do
      before { subject.omit_empty_attrs = nil }

      its(:omit_empty_attrs) { should == false }
    end

    context "when given a word other than true" do
      before { subject.omit_empty_attrs = ' Shaboosh' }

      its(:omit_empty_attrs) { should == false }
    end

    context "when given true" do
      before { subject.omit_empty_attrs = 'True' }

      its(:omit_empty_attrs) { should == true }
    end
  end
end
