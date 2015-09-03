# Description
#   Fetches a random active product from Etsy based on search criteria.
#
# Commands:
#   hubot etsy me <query> - random active product from Etsy based on <query>
#
#
# API note: to get an API key, go to https://www.etsy.com/developers/documentation/getting_started/register

module.exports = (robot) ->
  robot.respond /etsy me (.*)/i, slackEnabled: true, (msg) ->

    unless process.env.HUBOT_ETSY_API_KEY?
        msg.reply "I don't have an API key yet, can't even etsy. Please make sure HUBOT_ETSY_API_KEY is set in the environment and try again?"
        return


    # Call the Etsy API
    msg.http("https://openapi.etsy.com/v2/listings/active")
      .query
        api_key:   process.env.HUBOT_ETSY_API_KEY
        fields:    'title,url'
        includes:  'MainImage'
        keywords:  msg.match[1]
        limit:     25
        sort_on:   'score'
      .headers
        'Accept': 'application/json'
      .get() (err, res, body) =>
        json = JSON.parse(body)
        result = json.results?[Math.floor(Math.random() * (json.results.length))]

        # Grab the 570px image, if it exists.
        # Other available sizes: 75x75, 170x135
        img = result?.MainImage?.url_570xN



        # Print out the result, if we got one
        msg.send img if img
        if result
          msg.send "[#{result.title}](#{result.url})"
        else
          msg.send "Sorry, nobody has made \"#{msg.match[1]}\". Maybe you'd like to knit one?"
