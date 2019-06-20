require 'twitter'

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV["CONSUMER_API_KEY"]
  config.consumer_secret     = ENV["CONSUMER_API_SECRET"]
  config.access_token        = ENV["ACCESS_TOKEN"]
  config.access_token_secret = ENV["ACCESS_SECRET"]
end

me           = client.user
max_id       = 0
trash_tweets = []
cutoff_date  = Date.today - 30

loop do
  puts "trash_tweets: #{trash_tweets.inspect}"
  puts "max_id: #{max_id}"

  tweets = if max_id > 0
    client.user_timeline(me, count: 200, max_id: max_id)
  else
    client.user_timeline(me, count: 200)
  end

  break if tweets.length == 1

  puts "tweets downloaded: #{tweets.count}"

  tweets.each do |tweet|
    date = tweet.created_at.to_date

    if date < cutoff_date
      trash_tweets << tweet
    end
  end

  max_id = tweets.last.id

  puts "destroying #{trash_tweets.count} tweets"
  client.destroy_status(trash_tweets)
  trash_tweets = []
end
