export someNewFunc = ->
  console.log 'somenewfunc works!'

export getFrameByPattern = (pattern) ->
  iframe = document.querySelector(pattern)
  if not iframe? or not iframe.contentWindow?
    return
  for x in window.frames
    if x == iframe.contentWindow
      return x

#window.addEventListener

console.log 'inject added to ' + window.location.href
#console.log 'frameElement is '
#console.log window.frameElement

/*
sendLocation = ->
  console.log 'calling sendLocation from ' + window.location.href
  parent.postMessage {type: 'sendlocation', location: window.location.href}, '*'

setInterval sendLocation, 2000
*/

/*
window.addEventListener 'message', (evt, sender) ->
  #console.log 'message received'
  #console.log evt
  if not evt? or not evt.data?
    return
  etype = evt.data.type
  if not etype?
    return
  console.log 'message received'
  console.log evt
  if etype == 'getlocation'
    #iframeid = evt.data.iframeid
    location = window.location.href
    #console.log 'srcElement.frameElement'
    #console.log evt.srcElement.frameElement
    #console.log 'source.frameElement'
    #console.log evt.source.frameElement
    #console.log 'target.frameElement'
    #console.log evt.target.frameElement
    #console.log 'currentTarget.frameElement'
    #console.log evt.currentTarget.frameElement
    #framesrc = 'none'# window.frameElement.src
    evt.source.postMessage {type: 'sendlocation', location}, '*'#evt.origin
*/
/*
if etype == 'sendlocation'
  console.log 'received location'
  console.log evt
  console.log sender
  console.log 'srcElement.frameElement'
  console.log evt.srcElement.frameElement
  console.log 'source.frameElement'
  console.log evt.source.frameElement
  console.log 'target.frameElement'
  console.log evt.target.frameElement
  console.log 'currentTarget.frameElement'
  console.log evt.currentTarget.frameElement
  #console.log window.frameElement
  #console.log evt.source.frameElement.src
*/

/*
setInterval ->
  parent.postMessage 'hello world', '*' 
, 2000

window.addEventListener 'message', (evt, sender) ->
  console.log 'message received'
  console.log evt
  console.log evt.source.
  console.log sender
*/