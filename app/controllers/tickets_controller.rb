require 'digest'
require 'net/http'
require 'uri'
require 'json'
KEY = ENV['key']
MARKER = ENV['marker']

class TicketsController < ApplicationController
  skip_before_action :authorized

  def index
    signature = get_signature(params)

    uri = URI.parse("http://api.travelpayouts.com/v1/flight_search")
    header = { 'Content-type': 'application/json' }
    search_body = {
      "signature": signature,
      "marker": MARKER,
      "host": "flightix.com",
      "user_ip": "127.0.0.1",
      "locale": "en",
      "trip_class": params[:flightClass],
      "passengers": {
        "adults": params[:adults],
        "children": 0,
        "infants": params[:infants]
      },
      "segments":
        if params[:dateOfReturn] != nil
          [{
             "origin": params[:from],
             "destination": params[:to],
             "date": params[:dateOfDep]
           },
           {
             "origin": params[:to],
             "destination": params[:from],
             "date": params[:dateOfReturn]
           }]
        else
          [{
             "origin": params[:from],
             "destination": params[:to],
             "date": params[:dateOfDep]
           }]
        end
    }

    # Create the HTTP objects
    http = Net::HTTP.new(uri.host)
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.body = search_body.to_json

    # Send the request and get search_id
    response = http.request(request)
    search_id = JSON.parse(response.body)['search_id']
    currency = JSON.parse(response.body)['currency']
    if currency != 'usd'
      currency_rate = JSON.parse(response.body)['currency_rates']['usd']
    end

    uri_search = URI.parse("http://api.travelpayouts.com/v1/flight_search_results?uuid=#{search_id}")
    header_search = { 'Accept-Encoding': 'gzip,deflate,sdch'}
    http_search = Net::HTTP.new(uri_search.host)
    request_search = Net::HTTP::Get.new(uri_search.request_uri, header_search)
    response_search = http_search.request(request_search)

    proposals = JSON.parse(response_search.body)
    tickets = proposals[0]["proposals"]
    if tickets == nil
      tickets = []
    end
    render json: {
      tickets: tickets,
      currency_rate: currency_rate,
      search_id: search_id
    }

    process_tickets(params, tickets, currency_rate)
  end

  def get_view_deal_url
    uri = URI.parse("http://api.travelpayouts.com/v1/flight_searches/#{params[:search]}/clicks/#{params[:terms]}.json")
    http_search = Net::HTTP.new(uri.host)
    request_search = Net::HTTP::Get.new(uri.request_uri)
    response_search = http_search.request(request_search)

    term = JSON.parse(response_search.body)
    url = term["url"]
    render  json: {url: url}
  end

  def get_signature(params)
    trip = "#{KEY}:flightix.com:en:#{MARKER}:#{params[:adults]}:0:#{params[:infants]}:#{params[:dateOfDep]}:#{params[:to]}:#{params[:from]}"
    if params[:dateOfReturn] != nil
      trip = trip + ":#{params[:dateOfReturn]}:#{params[:from]}:#{params[:to]}"
    end
    message = trip + ":#{params[:flightClass]}:127.0.0.1"

    md5 = Digest::MD5.new
    md5.update message
    md5.hexdigest
  end

  def show
    ticket = Ticket.find_by(id: params[:id])
    render json: ticket
  end

  def process_tickets(params, tickets, currency_rate)
    plans = Plan.where(IATA_from: params[:from],
                 date_of_departure: params[:dateOfDep],
                 IATA_to: params[:to],
                 date_of_return: params[:dateOfReturn],
                 adults: params[:adults],
                 infants: params[:infants],
                 flight_class: params[:flightClass]).all

    if plans == nil
      return
    end

    if tickets.length == 0
      return
    end

    term = tickets[0]['terms'][tickets[0]['terms'].keys[0]]
    if  term['currency'] != 'usd'
      price = (term['price'] / currency_rate).round(0)
    else
      price = term['price']
    end

    plans.each do |plan|
      Ticket.find_or_create_by(
        plan_id: plan.id,
        price: price
      )
    end
  end
end
