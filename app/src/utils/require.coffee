require_script = (url, callback) ->
  script = document.createElement('script')
  script.type = 'text/javascript'
  script.src = '../src/' + url + '.js' + '?' + (new Date().getTime())
  if callback?
      script.onreadystatechange = callback;
      script.onload = script.onreadystatechange;
  document.getElementsByTagName('head')[0].appendChild(script)

@require = (urls, callback) ->
  self = this
  if (urls instanceof Array)
    index = -1
    require_array = ->
      if (index + 1 < urls.length)
        require_script(urls[++index], require_array)
      else
        callback.bind(self)()
    do require_array
  else
    require_script(urls, callback.bind(self))