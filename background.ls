
if require? and not easylist_text? and not ABPFilterParser?
  ``
  require('es6-shim')
  ABPFilterParser = require('abp-filter-parser')
  easylist_text = require('./easylist_text').easylist_text
  ``

parsed_filter_data = {}
ABPFilterParser.parse easylist_text, parsed_filter_data

#url_to_check = 'http://static.tumblr.com/dhqhfum/WgAn39721/cfh_header_banner_v2.jpg'
#domain = '/static.tumblr.com'

elementTypeMasks = {
  script: 1
  image: 2
  stylesheet: 4
  object: 8
  xtlhttprequest: 16
  'object-subrequest': 32
  subdocument: 64
  document: 128
  other: 256
  # custom added
  img: 2
  iframe: 64
}

is_request_ad = (request) ->
  {url, domain, elemtype} = request
  if typeof(url) == 'string'
    url = [url]
  abp_options = {domain}
  if elemtype?
    bitwise_mask = elementTypeMasks[elemtype]
    if not bitwise_mask?
      console.log 'missing elementTypeMasks for ' + elemtype
    else
      abp_options.elementTypeMaskMap = bitwise_mask
  for current_url in url
    if ABPFilterParser.matches(parsed_filter_data, current_url, abp_options)
      return true
  return false

#console.log is_request_ad {domain: '/www.nytimes.com', url: 'google_ads_iframe_/29390238/NYT/world/europe_2'}

#if not (chrome? and chrome.runtime?) and process? and process.exit?
#  process.exit()

chrome.runtime.onMessage.addListener (request, sender, callback) ->
  if not request? or not request.type?
    return
  if request.type == 'isblocked'
    if request.iswindow
      console.log sender
      console.log request
      is_ad = is_request_ad request
      console.log is_ad
      callback is_ad
      return
    callback is_request_ad request
