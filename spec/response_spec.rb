require 'minitest_helper'

describe Hobbit::Response do
  describe '#initialize' do
    let :default_headers do
      { 'Content-Type' => 'text/html; charset=utf-8' }
    end

    it 'must set the body, status and headers with no arguments given' do
      response = Hobbit::Response.new
      response.status.must_equal 200
      response.headers.must_equal default_headers
      response.body.must_equal []
    end

    it 'must set the body, status and headers with arguments given' do
      status, headers, body = 200, { 'Content-Type' => 'application/json' }, ['{"name": "Hobbit"}']
      response = Hobbit::Response.new body, status, headers
      response.status.must_equal status
      response.headers.must_equal headers
      response.body.must_equal body
    end

    it 'must set the body if the body is a string' do
      response = Hobbit::Response.new 'hello world'
      response.status.must_equal 200
      response.headers.must_equal default_headers
      response.body.must_equal ['hello world']
    end

    it 'must raise a TypeError if body does not respond to :to_str or :each' do
      proc { Hobbit::Response.new 1 }.must_raise TypeError
    end
  end

  describe '#[]' do
    let(:response) { Hobbit::Response.new }

    it 'must respond to #[]' do
      response.must_respond_to :[]
    end

    it 'must return a header' do
      response['Content-Type'].must_equal 'text/html; charset=utf-8'
    end
  end

  describe '#[]=' do
    let(:response) { Hobbit::Response.new }

    it 'must respond to #[]=' do
      response.must_respond_to :[]=
    end

    it 'must set a header' do
      content_type = 'text/html; charset=utf-8'
      response['Content-Type'] = content_type
      response['Content-Type'].must_equal content_type
    end
  end

  describe '#finish' do
    let(:status) { 200 }
    let(:headers) { { 'Content-Type' => 'application/json' } }
    let(:body) { ['{"name": "Hobbit"}'] }

    it 'must return a 3 elements array with status, headers and body' do
      response = Hobbit::Response.new body, status, headers
      response.finish.must_equal [status, headers, body]
    end

    it 'must calculate the Content-Length of the body' do
      response = Hobbit::Response.new body, status, headers
      s, h, b = response.finish
      h.must_include 'Content-Length'
      h['Content-Length'].must_equal '18'
    end

    it 'must calculate the Content-Length of the body, even if the body is empty' do
      response = Hobbit::Response.new
      s, h, b = response.finish
      h.must_include 'Content-Length'
      h['Content-Length'].must_equal '0'
    end
  end

  describe '#redirect' do
    let(:response) { Hobbit::Response.new }

    it 'must set the Location header and the status code' do
      response.redirect '/hello'
      response.headers['Location'].must_equal '/hello'
      response.status.must_equal 302
    end

    it 'must set the Location header and the status code if given' do
      response.redirect '/hello', 301
      response.headers['Location'].must_equal '/hello'
      response.status.must_equal 301
    end
  end

  describe '#write' do
    let(:response) { Hobbit::Response.new }

    it 'must append the argument to the body of the response' do
      response.write 'hello world'
      response.body.must_equal ['hello world']
    end
  end
end
