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
        w: 200
        h: 200
      pos:
        x: 1400
        y: 400

    @catapultBase = new Sprite @ctx,
      texture: '/images/catapult_base.png'
      size:
        w: 200
        h: 142
      pos:
        x: 200
        y: 938

    @catapultArm = new CatapultArm @ctx,
      texture: '/images/catapult_arm.png'
      size:
        w: 200
        h: 142
      pos:
        x: 210
        y: 880

    @sprites = [@envelope, @catapultArm, @catapultBase]

  run: ->
    setInterval ( =>
      @_clear()
      @render()
    ), 20
    @_controlCatapult()

  _resizeCanvas: ->
    @canvas.height @canvas.parent().height()
    @canvas.width @canvas.height() / 9 * 16
    @canvas.parent().css 'max-width', @canvas.width()
    @ctx.w = @canvas.width()
    @ctx.h = @canvas.height()

  _clear: =>
    @ctx.clearRect 0, 0, 1920, 1080

  render: =>
    @sprites.forEach (s) -> s.draw()

  _controlCatapult: =>
    isPressed = false
    mY = 0
    startPosition = 0

    @canvas.on 'mousedown touchstart', (e) =>
      e.pageY = e.originalEvent.touches[0].pageY if e.originalEvent.touches
      e.pageY = e.originalEvent.changedTouches[0].pageY if e.originalEvent.changedTouches
      isPressed = true
      startPosition = e.pageY

    @canvas.on 'mouseup touchend', =>
      isPressed = false
      @catapultArm.currentAngle = 0
      mY = 0
      startPosition = 0

    @canvas.on 'mousemove touchmove', (e) =>
      if isPressed
        e.pageY = e.originalEvent.touches[0].pageY if e.originalEvent.touches
        e.pageY = e.originalEvent.changedTouches[0].pageY if e.originalEvent.changedTouches
        if (e.pageY < mY) and (@catapultArm.currentAngle < 0)
          @catapultArm.currentAngle = startPosition - e.pageY
        else if @catapultArm.currentAngle > -@catapultArm.availableAngle
          @catapultArm.currentAngle = startPosition - e.pageY
        mY = e.pageY



class Sprite
  constructor: (ctx, obj) ->
    @ctx = ctx
    @img = new Image()
    @_loadImage(obj.texture)
    @size = obj.size
    @pos = obj.pos

  draw: ->
    @ctx.drawImage @img, @pos.x, @pos.y, @size.w, @size.h

  _loadImage: (url) =>
    img = new Image
    img.src = url
    img.onload = =>
      @img = img

class Envelope extends Sprite
  constructor: (ctx, obj) ->
    super(ctx, obj)
    @direction = 3
    @availableHeight = 100
    @startPosition = $.extend true, {}, obj.pos
    @notifications = 0

  draw: ->
    @pos.y += @direction
    @_checkBounds()
    super()
    @_drawNotifications()

  _checkBounds: =>
    if (@pos.y < (@startPosition.y - @availableHeight)) || (@pos.y > (@startPosition.y + @availableHeight))
          @direction *= -1

  _drawNotifications: =>
    if @notifications > 0
      radius = 30
      @ctx.beginPath()
      @ctx.arc(@pos.x + @size.w, @pos.y, radius, 0, 2 * Math.PI, false)
      @ctx.fillStyle = 'red'
      @ctx.fill()
      @ctx.font = "bold #{radius}px sans-serif"
      @ctx.textBaseline = 'middle'
      @ctx.textAlign = 'center'
      @ctx.fillStyle = 'white'
      @ctx.fillText @notifications, @pos.x + @size.w, @pos.y, radius

class CatapultArm extends Sprite
  constructor: (ctx, obj) ->
    super(ctx, obj)
    @availableAngle = 70
    @currentAngle = 0

  draw: ->
    @ctx.save()
    @ctx.strokeStyle
    @ctx.translate(@pos.x + (@size.w / 2), @pos.y + (@size.h / 2))
    @ctx.rotate @_toRadians(@currentAngle)
    @ctx.drawImage @img, -(@size.w / 2), -(@size.h / 2), @size.w, @size.h
    @ctx.restore()

  _toRadians: (angle) ->
    angle * (Math.PI / 180)

@app = new Game('#game')
@app.run()
