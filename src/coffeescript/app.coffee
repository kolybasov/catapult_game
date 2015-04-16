class Game
  constructor: (el) ->
    @canvas = $(el)
    @ctx = @canvas[0].getContext('2d')
    @_resizeCanvas()
    # $(window).on 'resize', =>
    #   @_resizeCanvas()

  run: ->
    setInterval @_draw, 20

  _resizeCanvas: ->
    @canvas.width @canvas.parent().width()
    @canvas.height @canvas.parent().height()

  _draw: =>
    console.log 'Drawing!'


(new Game('#game')).run()
