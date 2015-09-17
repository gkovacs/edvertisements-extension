require 'es6-shim'

require! {
  fs
}

easylist_text = fs.readFileSync 'easylist_noelemhide.txt', 'utf-8'
fs.writeFileSync 'easylist_text.js', '''(function(){
  var out$ = typeof exports != 'undefined' && exports || this;
  out$.easylist_text = ''' + JSON.stringify(easylist_text, null, 2) + ''';
}).call(this);'''
#ABPFilterParser = require 'abp-filter-parser'

#console.log easylist_text

#parsed_filter_data = {}
#ABPFilterParser.parse easylist_text, parsed_filter_data

#console.log parsed_filter_data

#fs.writeFileSync 'easylist.ls', 'export easylist = ' + JSON.stringify(parsed_filter_data, null, 2)

/*
url_to_check = 'http://static.tumblr.com/dhqhfum/WgAn39721/cfh_header_banner_v2.jpg'

domain = '/static.tumblr.com'

#console.log ABPFilterParser.matches(parsed_filter_data, url_to_check, {domain: domain, elementTypeMaskMap: ABPFilterParser.elementTypes.SCRIPT})
console.log ABPFilterParser.matches(parsed_filter_data, url_to_check, {domain})
*/
