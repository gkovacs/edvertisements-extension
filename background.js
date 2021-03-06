// Generated by LiveScript 1.4.0
(function(){
  var parsed_filter_data, elementTypeMasks, is_request_ad;
  if ((typeof require != 'undefined' && require !== null) && (typeof easylist_text == 'undefined' || easylist_text === null) && (typeof ABPFilterParser == 'undefined' || ABPFilterParser === null)) {
    
    require('es6-shim')
    ABPFilterParser = require('abp-filter-parser')
    easylist_text = require('./easylist_text').easylist_text
    
  }
  parsed_filter_data = {};
  ABPFilterParser.parse(easylist_text, parsed_filter_data);
  elementTypeMasks = {
    script: 1,
    image: 2,
    stylesheet: 4,
    object: 8,
    xtlhttprequest: 16,
    'object-subrequest': 32,
    subdocument: 64,
    document: 128,
    other: 256,
    img: 2,
    iframe: 64
  };
  is_request_ad = function(request){
    var url, domain, elemtype, abp_options, bitwise_mask, i$, len$, current_url;
    url = request.url, domain = request.domain, elemtype = request.elemtype;
    if (typeof url === 'string') {
      url = [url];
    }
    abp_options = {
      domain: domain
    };
    if (elemtype != null) {
      bitwise_mask = elementTypeMasks[elemtype];
      if (bitwise_mask == null) {
        console.log('missing elementTypeMasks for ' + elemtype);
      } else {
        abp_options.elementTypeMaskMap = bitwise_mask;
      }
    }
    for (i$ = 0, len$ = url.length; i$ < len$; ++i$) {
      current_url = url[i$];
      if (ABPFilterParser.matches(parsed_filter_data, current_url, abp_options)) {
        return true;
      }
    }
    return false;
  };
  chrome.runtime.onMessage.addListener(function(request, sender, callback){
    var is_ad;
    if (request == null || request.type == null) {
      return;
    }
    if (request.type === 'isblocked') {
      if (request.iswindow) {
        console.log(sender);
        console.log(request);
        is_ad = is_request_ad(request);
        console.log(is_ad);
        callback(is_ad);
        return;
      }
      return callback(is_request_ad(request));
    }
  });
}).call(this);
