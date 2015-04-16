class Game
  constructor: (el) ->
    @canvas = $(el)
    @ctx = @canvas[0].getContext('2d')
    @_resizeCanvas()
    $(window).on 'resize', =>
      @_resizeCanvas()

    @envelope = new Envelope @ctx,
      texture: '/images/email_logo.png'
      size:
        w: 100
        h: 100
      position:
        x: 1500
        y: 200

    @catapultBase = new Sprite @ctx,
      texture: '/images/catapult_base.png'
      size:
        w: 200
        h: 142
      position:
        x: 200
        y: 800

    @catapultArm = new CatapultArm @ctx,
      texture: '/images/catapult_arm.png'
      size:
        w: 200
        h: 142
      position:
        x: 200
        y: 740

    @sprites = [@envelope, @catapultArm, @catapultBase]

  run: ->
    setInterval ( =>
      @_clear()
      @_draw()
    ), 20

  _resizeCanvas: ->
    @canvas.height @canvas.parent().height()
    @canvas.width @canvas.height() / 9 * 16
    @canvas.parent().css 'max-width', @canvas.width()

  _clear: =>
    @ctx.clearRect 0, 0, 1920, 1080

  _draw: =>
    @sprites.forEach (s) -> s.draw()


class Sprite
  constructor: (ctx, obj) ->
    @ctx = ctx
    @img = new Image()
    @_loadImage(obj.texture)
    @size = obj.size
    @position = obj.position

  draw: ->
    @ctx.drawImage @img, @position.x, @position.y, @size.w, @size.h

  _loadImage: (url) =>
    img = new Image
    img.src = url
    img.onload = =>
      @img = img

class Envelope extends Sprite
  constructor: (ctx, obj) ->
    super(ctx, obj)
    @direction = 1
    @availableHeight = 50
    @startPosition = $.extend true, {}, obj.position
    @notifications = 1

  draw: ->
    @position.y += @direction
    @_checkBounds()
    super()
    @_drawNotifications()

  _checkBounds: =>
    if (@position.y < (@startPosition.y - @availableHeight)) || (@position.y > (@startPosition.y + @availableHeight))
          @direction *= -1

  _drawNotifications: =>
    if @notifications > 0
      radius = 20
      @ctx.beginPath()
      @ctx.arc(@position.x + @size.w, @position.y, radius, 0, 2 * Math.PI, false)
      @ctx.fillStyle = 'red'
      @ctx.fill()
      @ctx.font = "bold #{radius}px sans-serif"
      @ctx.textBaseline = 'middle'
      @ctx.textAlign = 'center'
      @ctx.fillStyle = 'white'
      @ctx.fillText @notifications, @position.x + @size.w, @position.y, radius

class CatapultArm extends Sprite
  constructor: (ctx, obj) ->
    super(ctx, obj)
    @availableAngle = 50

@app = new Game('#game')
@app.run()
