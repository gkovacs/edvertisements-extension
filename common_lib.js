if (require) {
  parseUri = require('./functions').parseUri
}

if (typeof document == 'undefined') {
  document = {
    location: 'static.tumblr.com'
  }
}

var elementPurger = {
  // Return a list of { op, text }, where op is a CSS selector operator and
  // text is the text to select in a src attr, in order to match an element on
  // this page that could request the given absolute |url|.
  _srcsFor: function(url) {
    // NB: <img src="a#b"> causes a request for "a", not "a#b".  I'm
    // intentionally ignoring IMG tags that uselessly specify a fragment.
    // AdBlock will fail to hide them after blocking the image.
    var url_parts = parseUri(url), page_parts = this._page_location;
    var results = [];
    // Case 1: absolute (of the form "abc://de.f/ghi" or "//de.f/ghi")
    results.push({ op:"$=", text: url.match(/\:(\/\/.*)$/)[1] });
    if (url_parts.hostname === page_parts.hostname) {
      var url_search_and_hash = url_parts.search + url_parts.hash;
      // Case 2: The kind that starts with '/'
      results.push({ op:"=", text: url_parts.pathname + url_search_and_hash });
      // Case 3: Relative URL (of the form "ab.cd", "./ab.cd", "../ab.cd" and
      // "./../ab.cd")
      var page_dirs = page_parts.pathname.split('/');
      var url_dirs = url_parts.pathname.split('/');
      var i = 0;
      while (page_dirs[i] === url_dirs[i]
             && i < page_dirs.length - 1
             && i < url_dirs.length - 1) {
        i++; // i is set to first differing position
      }
      var dir = new Array(page_dirs.length - i).join("../");
      var path = url_dirs.slice(i).join("/") + url_search_and_hash;
      if (dir) {
        results.push({ op:"$=", text: dir + path });
      } else {
        results.push({ op:"=", text: path });
        results.push({ op:"=", text: "./" + path });
      }
    }

    return results;
  },

  // To enable testing
  _page_location: document.location
};


  console.log(elementPurger._srcsFor('http://static.tumblr.com/dhqhfum/WgAn39721/cfh_header_banner_v2.jpg'))
  //console.log(parseUri('http://static.tumblr.com/dhqhfum/WgAn39721/cfh_header_banner_v2.jpg'))