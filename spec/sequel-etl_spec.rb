require 'sequel-etl'

def test_connections
  adapter = RUBY_ENGINE == 'jruby' ? 'jdbc:sqlite' : 'sqlite'
  @connections ||= {source: Sequel.connect("#{adapter}://memory"), destination: Sequel.connect("#{adapter}://memory")}
end

def reset_test_env(connections)

end

describe Sequel::ETL do
  let(:logger) { nil }
  let (:etl) { described_class.new }
  describe '#perform' do
    let(:connections) { test_connections }
    let(:etl) { described_class.new connections: connections, logger: logger }
    before do
      reset_test_env(connections)
      # insert test data
    end

    it "executes the specified sql in the appropriate order" do

    end
  end

  describe '#perform with operations specified for exclusion' do
    let(:connections) { double }
    let(:etl)        { described_class.new connections: connections, logger: logger }
    it "does not call the specified method" do
      etl.ensure_destination {}
      etl.should_not_receive(:ensure_destination)
      etl.run except: :ensure_destination
    end
  end

  context "with iteration" do
    describe '#run over full table' do
      let(:connections) { test_connections }
      let(:etl)        { described_class.new connections: connections, logger: logger }
      before { reset_test_env connections }
      it "executes the specified sql in the appropriate order and ETLs properly" do

      end
    end
    describe "#run over part of table" do
      let(:connections) { test_connections }
      let(:etl)        { described_class.new connections: connections, logger: logger }

      before { reset_test_env connections }
      it "executes the specified sql in the appropriate order and ETLs properly" do

      end
    end
    describe "#run over gappy data" do
      let(:connections) { test_connections }
      let(:etl)        { described_class.new connections: connections, logger: logger }

      before do
        reset_test_env(connections) do |connections|
          # make gappy data
        end
      end

      it "executes the specified sql in the appropriate order without getting stuck" do

      end
    end
    describe "#run over date data" do
      let(:connections) { test_connections }
      let(:etl)        { described_class.new connections: connections, logger: logger }

      before do
        reset_test_env(connections) do |connections|
          # make date data
        end
      end
      it "executes the specified sql in the appropriate order and ETLs properly" do

      end

    end

    describe "#run over datetime data" do
      let(:connections) { test_connections }
      let(:etl)        { described_class.new connections: connections, logger: logger }

      before do
        reset_test_env(connections) do |connections|
          # make datetime data
        end
      end
      it "executes the specified sql in the appropriate order and ETLs properly" do

      end
    end
  end
end
