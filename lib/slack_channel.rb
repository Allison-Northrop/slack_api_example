class SlackChannel
  class SlackException < RuntimeError
  end

  BASE_URL = "https://slack.com/api"


  attr_reader :name, :raw_data

  def initialize(data)
    @name = data["name"]#string keys because it comes from JSON data
    @raw_data = data #probably won't need this but it doesn't hurt to have it
  end

  def send(message)
    #extra data
    query_params = {
      "token" => ENV["SLACK_API_TOKEN"],
      "channel" => @name,
      "text" => message,
      "username" => "Benny Frank",
      "icon_emoji" => ":robot_face:",
      "as_user" => "false"
    }

    url = "#{BASE_URL}/chat.postMessage"
    response = HTTParty.post(url, query: query_params)
    #do something with the response?
    if response["ok"]
      puts "everything went swell"
    else
      raise SlackException.new(response["error"])
    end
  end

  def self.all
    url = "#{BASE_URL}/channels.list?token=#{ENV["SLACK_API_TOKEN"]}"
    response = HTTParty.get(url).parsed_response

    if response ["ok"]
      channel_list = []
      response["channels"].each do |channel_data|
        channel_list << self.new(channel_data)
      end

      return channel_list
    else
      raise SlackException.new(response["error"])
    end
  end

end
