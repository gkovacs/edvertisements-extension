coverElem = (iframeuid, tag) ->
  jtag = $(tag)
  # {left, top} = jtag.offset()
  {left, top} = jtag.position()
  # {left, top} = tag.getBoundingClientRect()
  # console.log {left, top}
  coverelem = $('<div>')
  #console.log 'coverlem called for iframeuid ' + iframeuid
  coverelem[0].setAttribute 'iframeuid', iframeuid
  coverelem.css 'display', jtag.css('display')
  coverelem.css {
    'position': 'absolute'
    'z-index': Number.MAX_VALUE
    'background-color': 'yellow'
    'width': jtag.width()
    'height': jtag.height()
    'top': top
    'left': left
  }
  #newelem.addClass('coveradvertisementelem')
  coverelem.click ->
    $(this).hide()
  parent = jtag.parent()
  if not parent? or parent.length == 0
    parent = $('html')
  coverelem.appendTo parent #'body'
  return

updateCoverElem = (iframeuid, tag) ->
  jtag = $(tag)
  #console.log 'updateCoverElem called for ' + iframeuid
  # {left, top} = jtag.offset()
  {left, top} = jtag.position()
  coverelem = $('div[iframeuid="' + iframeuid + '"]')
  coverelem.css 'display', jtag.css('display')
  coverelem.css {
    'position': 'absolute'
    'z-index': Number.MAX_VALUE
    'background-color': 'yellow'
    'width': jtag.width()
    'height': jtag.height()
    'top': top
    'left': left
  }
  return

``
// Remove an element from the page.
function destroyElement(el, elType) {
  if (el.nodeName == "FRAME") {
    removeFrame(el);
  }
  else if (elType != ElementTypes.script) {
    // There probably won't be many sites that modify all of these.
    // However, if we get issues, we might have to set the location and size
    // via the css properties position, left, top, width and height
    el.style.setProperty("display", "none", "important");
    el.style.setProperty("visibility", "hidden", "important");
    el.style.setProperty("opacity", "0", "important");
    var w = (el.width === undefined ? -1 : el.width);
    var h = (el.height === undefined ? -1 : el.height);
    el.style.setProperty("background-position", w + "px " + h + "px");
    el.setAttribute("width", 0);
    el.setAttribute("height", 0);
  }
}
``

``
function injectJs(link) {
        var idname = 'injected_' + link
        //if (document.getElementById(idname)) return;
        var scr = document.createElement("script");
        scr.id='injected_' + link
        scr.type="text/javascript";
        scr.src=link;
        (document.head || document.body || document.documentElement).appendChild(scr);
}
``

injectUtil = ->
  injectJs chrome.extension.getURL("inject.js")

#if top == window
#  injectUtil()

getGoodAdIframeSrc = (width, height) ->
  if not width?
    width = 200
  if not height?
    height = 200
  return baseurl + '/edv.html?' + $.param({width, height})

check_if_blocked = (data, callback) ->
  data.type = 'isblocked'
  data.domain = '/' + window.location.hostname
  chrome.runtime.sendMessage data, callback

check_if_iframe_blocked = (data, callback) ->
  if not data.url?
    data = {url: data}
  data.elemtype = 'iframe'
  check_if_blocked data, callback

check_if_img_blocked = (data, callback) ->
  if not data.url?
    data = {url: data}
  data.elemtype = 'img'
  check_if_blocked data, callback

if top != window
  whitelist = {
    'localhost'
    'feedlearn.herokuapp.com'
  }
  if whitelist[window.location.hostname]?
    return
  #top.postMessage {type: 'contentscriptloaded', location: window.location.href}, '*'
  #isblocked = true
  #chrome.runtime.sendMessage {type: 'isblocked', domain, elemtype: 'iframe', url: window.location.href}, (isblocked) ->
  #do ->
  check_if_iframe_blocked window.location.href, (isblocked) ->
    console.log 'trying to block, first try: ' + window.location.toString()
    #console.log window
    #console.log window.frameElement
    if isblocked
      setInterval ->
        console.log 'trying to block, but unsuccessful: ' + window.location.toString()
      , 2000
      #window.location.href = 'about:blank'
      #window.location.href = '//feedlearn.herokuapp.com'
      window.location.href = getGoodAdIframeSrc(window.innerWidth, window.innerHeight)
/*
else
  content_scripts = []
  window.addEventListener 'message', (evt) ->
    if not evt? or not evt.data?
      return
    etype = evt.data.type
    if not etype?
      return
    if etype == 'contentscriptloaded'
      {location} = evt.data
      if content_scripts.indexOf(location) == -1
        content_scripts.push location
        console.log 'content_scripts loaded:'
        console.log content_scripts
*/

block_img_tags = (basedoc) ->
  domain = '/' + window.location.hostname
  for let tag in basedoc.getElementsByTagName('img')
    if not tag.src or tag.checkedsrc == tag.src
      return
    check_if_img_blocked tag.src, (isblocked) ->
      tag.checkedsrc = tag.src
      if isblocked
        tag.src = ''
        tag.checkedsrc = tag.src

is_iframe_ad = (iframe, callback) ->
  urls_to_check = [x for x in [iframe.src, iframe.id, iframe.name] when x? and x.length > 0]
  console.log 'checking urls for iframe'
  console.log urls_to_check
  domain = '/' + window.location.hostname
  check_if_iframe_blocked urls_to_check, (isblocked) ->
    console.log 'isblocked:'
    callback isblocked

setInterval ->
  #console.log 'content script running'
  block_img_tags document
  for let iframe in document.getElementsByTagName('iframe')
    try
      #console.log iframe
      if iframe.src and iframe.src.length and iframe.src.length > 0 and iframe.alreadychecked == iframe.src
        return
      is_iframe_ad iframe, (is_ad) ->
        if is_ad
          iframe.src = getGoodAdIframeSrc($(iframe).width(), $(iframe).height())
          iframe.alreadychecked = iframe.src
      block_img_tags(iframe.contentDocument)
    catch
      return
  /*
  domain = '/' + window.location.hostname
  for let tagtype in ['img'] # ['img'] #, 'iframe']
    for let tag in document.getElementsByTagName(tagtype)
      #if tag.getAttribute 'isblocked'
      #  tag.setAttribute 'src', '//feedlearn.herokuapp.com'
  */
, 2000

#console.log 'contentscript loaded at ' + window.location.href

#sendLocation = ->
#  console.log 'calling sendLocation from ' + window.location.href
#  #parent.postMessage {type: 'sendlocation', location: window.location.href}, '*'
#  top.postMessage {type: 'sendlocation', location: window.location.href}, '*'

#setInterval sendLocation, 2000
#sendLocation()

#injectScriptInterval = null
#if window.frameElement?
#injectScriptInterval = setInterval injectUtil, 2000
#injectUtil()

window.addEventListener 'message', (evt, sender) ->
  #console.log 'message received'
  #console.log evt
  if not evt? or not evt.data?
    return
  etype = evt.data.type
  if not etype?
    return
  console.log 'contentscript received message'
  console.log evt
  if etype == 'getlocation'
    #console.log 'getlocation called'
    #console.log evt
    {iframeuid} = evt.data
    if not iframeuid?
      return
    location = window.location.href
    evt.source.postMessage {type: 'sendlocation', location, iframeuid}, '*'
    parent.postMessage {type: 'sendlocation', location, iframeuid}, '*'
  if etype == 'sendlocation'
    console.log 'received location'
    console.log evt
    #console.log sender
    #clearInterval injectScriptInterval
    {location, iframeuid} = evt.data
    #console.log 'sendlocation'
    #console.log {location, iframeuid}
    document.querySelector('iframe[iframeuid="' + iframeuid + '"]').setAttribute('realiframesrc', location)
    #iframe = evt.source.frameElement
    #if iframe?
    #  iframe.setAttribute 'realiframesrc', evt.data.location
    #console.log iframe

#sendLocation()

/*
setInterval ->
  #console.log 'content script running'
  domain = '/' + window.location.hostname
  for let tagtype in ['iframe'] # ['img'] #, 'iframe']
    for let tag in document.getElementsByTagName(tagtype)
      if tag.getAttribute 'isblocked'
        tag.setAttribute 'src', '//feedlearn.herokuapp.com'
, 2000
*/

/*
getIframeUID = (tag) ->
  iframeuid = tag.getAttribute('iframeuid')
  if iframeuid?
    return iframeuid
  iframeuid = Math.floor(1 + Math.random() * 999999999).toString()
  tag.setAttribute 'iframeuid', iframeuid
  return iframeuid

setInterval ->
  #console.log 'content script running'
  domain = '/' + window.location.hostname
  for let tagtype in ['iframe'] # ['img'] #, 'iframe']
    for let tag in document.getElementsByTagName(tagtype)
      iframeuid = getIframeUID(tag)
      #tag.contentWindow.postMessage {type: 'getlocation', iframename: 'sdfdalkfj'}, '*'
      iframesrc = tag.getAttribute('realiframesrc')
      if not iframesrc? or iframesrc.length == 0
        #console.log 'posting message to iframeuid: ' + iframeuid
        tag.contentWindow.postMessage {type: 'getlocation', iframeuid}, '*'
        return
      if iframesrc == tag.getAttribute('alreadychecked')
        if tag.getAttribute 'isiframeblocked'
          updateCoverElem iframeuid, tag
        return
      #console.log iframesrc
      #if tagtype == 'iframe'
      #  console.log tag
      tag.setAttribute 'alreadychecked', iframesrc
      #do ->
      chrome.runtime.sendMessage {type: 'isblocked', domain, elemtype: tagtype, url: [iframesrc]}, (isblocked) ->
        isblocked = true
        #console.log tag.src + ' isblocked: ' + isblocked
        tag.setAttribute 'isiframeblocked', isblocked
        if isblocked
          #console.log 'blocked ' + iframeuid + ' from ' + iframesrc
          coverElem iframeuid, tag
, 2000
*/