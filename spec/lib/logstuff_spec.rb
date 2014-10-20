require 'spec_helper'

describe Logstuff do


  describe '.log' do
    let(:logger) { LogStuff.new_logger('tempfile', Logger::INFO) }
    before do
      LogStuff.setup(:logger => logger)
      allow(LogStash::Time).to receive_messages(:now => 'timestamp')
      allow_message_expectations_on_nil
    end
    it 'adds to log with specified level' do
      #expect(logger).to receive(:send).with('warn?').and_return(true)
      expect(logger).to receive(:<<).with(%Q|{"@source":"logstuff","@tags":[],"@fields":{},"@severity":"warn","message":"WARNING","@timestamp":"timestamp"}\n|)
      LogStuff.log('warn') { 'WARNING' }
    end

    it 'adds to log with specified level and tags' do
      #expect(logger).to receive(:send).with('warn?').and_return(true)
      expect(logger).to receive(:<<).with(%Q|{"@source":"logstuff","@tags":["tag1","tag2"],"@fields":{},"@severity":"warn","message":"WARNING","@timestamp":"timestamp"}\n|)
      LogStuff.log('warn', :tag1, :tag2) { 'WARNING' }
    end

    it 'adds to log with specified level and hash' do
      #expect(logger).to receive(:send).with('warn?').and_return(true)
      expect(logger).to receive(:<<).with(%Q|{"@source":"logstuff","@tags":[],"@fields":{"key1":"value1","key2":"value2"},"@severity":"warn","message":"WARNING","@timestamp":"timestamp"}\n|)
      LogStuff.log('warn', :key1 => 'value1', :key2 => 'value2') { 'WARNING' }
    end

  end

  describe ".loglevel" do
  %w( fatal error warn info debug ).each do |severity|
    describe ".#{severity}" do
      let(:message) { "This is a #{severity} message" }
      let(:logger) { LogStuff.new_logger('tempfile', Logger::DEBUG) }
      before do
        LogStuff.setup(:logger => logger)
        allow(LogStash::Time).to receive_messages(:now => 'timestamp')
        allow_message_expectations_on_nil
      end
      it 'adds to log with specified level' do
        #expect(logger).to receive(:send).with('warn?').and_return(true)
        expect(logger).to receive(:<<).with(%Q|{"@source":"logstuff","@tags":[],"@fields":{},"@severity":"#{severity}","message":"#{message}","@timestamp":"timestamp"}\n|)
        LogStuff.send(severity) { message }
      end

      it 'adds to log with specified level and tags' do
        #expect(logger).to receive(:send).with('warn?').and_return(true)
        expect(logger).to receive(:<<).with(%Q|{"@source":"logstuff","@tags":["tag1","tag2"],"@fields":{},"@severity":"#{severity}","message":"#{message}","@timestamp":"timestamp"}\n|)
        LogStuff.send(severity, :tag1, :tag2) { message }
      end

      it 'adds to log with specified level and hash' do
        #expect(logger).to receive(:send).with('warn?').and_return(true)
        expect(logger).to receive(:<<).with(%Q|{"@source":"logstuff","@tags":[],"@fields":{"key1":"value1","key2":"value2"},"@severity":"#{severity}","message":"#{message}","@timestamp":"timestamp"}\n|)
        LogStuff.send(severity, :key1 => 'value1', :key2 => 'value2') { message }
      end
    end
  end
  end

  describe "block" do
    let(:severity) { "warn"}
    let(:message1) { "This is a #{severity} message 1" }
    let(:message2) { "This is a #{severity} message 2" }

    let(:logger) { LogStuff.new_logger('tempfile', Logger::DEBUG) }
    before do
      LogStuff.setup(:logger => logger)
      allow(LogStash::Time).to receive_messages(:now => 'timestamp')
      allow_message_expectations_on_nil
    end
    it 'adds tags only within a block' do
      #expect(logger).to receive(:send).with('warn?').and_return(true)
      expect(logger).to receive(:<<).with(%Q|{"@source":"logstuff","@tags":["tag1","tag2"],"@fields":{},"@severity":"#{severity}","message":"#{message1}","@timestamp":"timestamp"}\n|)
      expect(logger).to receive(:<<).with(%Q|{"@source":"logstuff","@tags":[],"@fields":{},"@severity":"#{severity}","message":"#{message2}","@timestamp":"timestamp"}\n|)

      LogStuff.tag(:tag1, :tag2) do
        LogStuff.warn { message1 }
      end
      LogStuff.warn { message2 }
    end

    it 'adds fields only within a block' do
      #expect(logger).to receive(:send).with('warn?').and_return(true)
      expect(logger).to receive(:<<).with(%Q|{"@source":"logstuff","@tags":[],"@fields":{"key1":"value1","key2":"value2"},"@severity":"#{severity}","message":"#{message1}","@timestamp":"timestamp"}\n|)
      expect(logger).to receive(:<<).with(%Q|{"@source":"logstuff","@tags":[],"@fields":{},"@severity":"#{severity}","message":"#{message2}","@timestamp":"timestamp"}\n|)

      LogStuff.metadata(:key1 => 'value1', :key2 => 'value2') do
        LogStuff.warn { message1 }
      end
      LogStuff.warn { message2 }
    end

  end




end
