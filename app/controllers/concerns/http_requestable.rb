# frozen_string_literal: true

module HttpRequestable
  require 'net/http'
  require 'uri'

  def post_request(url, body, headers = {})
    uri = URI.parse(url)
    request = Net::HTTP::Post.new(uri)
    request.set_form_data(body)
    headers.each { |key, value| request[key] = value }

    http = Net::HTTP.new(uri.hostname, uri.port)
    http.use_ssl = (uri.scheme == 'https')

    response = http.request(request)

    # Parse response based on Content-Type
    if response['Content-Type'].include?('application/json')
      JSON.parse(response.body)
    elsif response['Content-Type'].include?('application/x-www-form-urlencoded')
      URI.decode_www_form(response.body).to_h
    else
      raise "Unsupported Content-Type: #{response['Content-Type']}"
    end
  rescue JSON::ParserError => e
    raise "JSON Parsing Error: #{e.message} - Response: #{response.body}"
  rescue StandardError => e
    raise "Request Error: #{e.message}"
  end

  def get_request(url, headers = {})
    uri = URI.parse(url)
    request = Net::HTTP::Get.new(uri)
    headers.each { |key, value| request[key] = value }

    http = Net::HTTP.new(uri.hostname, uri.port)
    http.use_ssl = (uri.scheme == 'https')

    response = http.request(request)

    # Parse response based on Content-Type
    if response['Content-Type'].include?('application/json')
      JSON.parse(response.body)
    elsif response['Content-Type'].include?('application/x-www-form-urlencoded')
      URI.decode_www_form(response.body).to_h
    else
      raise "Unsupported Content-Type: #{response['Content-Type']}"
    end
  rescue JSON::ParserError => e
    raise "JSON Parsing Error: #{e.message} - Response: #{response.body}"
  rescue StandardError => e
    raise "Request Error: #{e.message}"
  end
end
