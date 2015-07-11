class window.StateMachineBox

    CLASS = @

    @MODES =
        SINGLE: "single"
        MANY:   "many"
    @MODE       = @MODES.SINGLE
    @FADE_TIME  = 180
    FADE_TIME   = @FADE_TIME

    @BUTTON_ACTIONS =
        OK:     "CLOSE"
        CANCEL: "CANCEL"
        NEXT:   "NEXT"
        PREV:   "PREV"

    @BUTTONS =
        OK:     """<div class="button ok">ok</div>"""
        CANCEL: """<div class="button cancel">cancel</div>"""
        NEXT:   """<div class="button next">next</div>"""
        PREV:   """<div class="button prev">prev</div>"""

    @ACTIONS:
        CLOSE: () ->
            return @close()
        OK: () ->
            @close(true)
            if @onOk instanceof Function
                @onOk()
            return @
        CANCEL: () ->
            @close(true)
            if @onCancel instanceof Function
                @onCancel()
            return @
        CHANGE: (idx) ->
            return @change(idx)
        NEXT: () ->
            return @next()
        PREV: () ->
            return @prev()

    @BUTTON_COLORS = [
        "#222222"
        "#9FA39F"
        "#B9BCB9"
        "#D3D5D3"
    ]

    @_popups        = []
    @_activePopup   = null

    @getTopMost = () ->
        popups = @_popups
        divs = $()

        for popup in popups
            divs = divs.add(popup.div)

        # return the popup whose div is the last visible one (= on top)
        return popups[divs.index(divs.filter(":visible:last"))] or null

    @_setActive: (popup) ->
        @_activePopup = popup
        return @

    @getActive: () ->
        return @_activePopup or @getTopMost()

    @registerPopup: (popup) ->
        if popup not in @_popups
            @_popups.push popup
        return @

    @unregisterPopup: (popup) ->
        idx = @_popups.indexOf popup
        if idx >= 0
            @_popups = (p for p in @_popups when i isnt idx)
        return @

    # CONSTRUCTOR
    constructor: (stateMachineConfig, headline, options = {}) ->
        if not stateMachineConfig? or not stateMachineConfig.events?
            throw new Error("StatePopup::constructor: No (valid) state machine configuration given!")
        # check for naming collisions
        for event in stateMachineConfig.events when @[event.name]?
            throw new Error("StatePopup::constructor: Trying to create event '#{event.name}' but that property already exists in popup!!")
        for callbackName, callback of stateMachineConfig.callbacks when @[callbackName]?
            throw new Error("StatePopup::constructor: Trying to create callback '#{callbackName}' but that property already exists in popup!!")

        @headline           = headline
        @options            = options
        @closeButtonAction  = options.closeButtonAction or "close"
        @onClose            = options.onClose
        @onOk               = options.onOk
        @onCancel           = options.onCancel
        @onNext             = options.onNext
        @onPrev             = options.onPrev
        @onChange           = options.onChange
        @beforeClose        = options.beforeClose
        @beforeNext         = options.beforeNext
        @beforePrev         = options.beforePrev
        @beforeChange       = options.beforeChange

        @onFailure          = options.onFailure

        @data       = {}

        @div        = $ """<div class="popup onTop" />"""
        @overlay    = $ """<div class="popup overlay onTop" />"""

        if options.width? and options.height?
            @div.css {
                width: options.width
                height: options.height
            }

        @loader     = null

        # taken from Popup.sass.erb
        @bodyWidth = parseFloat(@options.width) or 800
        @bodyPadding =
            top:    10
            right:  40
            bottom: 10
            left:   40

        @_active = false

        # apply state machine to only this instance
        stateMachineConfig.target = @

        # indicates whether or not the state machine can be linearized:
        #       state1.1
        #       /       \
        # initial       final
        #       \       /
        #       state1.2
        # can also be made linear => 2 options => initial -> state1.1 -> final OR initial -> state1.2 -> final
        # this options also implies the existence of the navigation bar
        if stateMachineConfig.linearization?
            @linearization = stateMachineConfig.linearization
        else
            @linearization = null

        @stateMachineConfig = stateMachineConfig
        @bodyWrapper        = null
        @contents           = {}
        for event in stateMachineConfig.events when event.content?
            @contents[event.to] = event.content

        self = @
        if not stateMachineConfig.callbacks?
            stateMachineConfig.callbacks = {}
        stateMachineConfig.callbacks.onenterstate = (event, from, to, params...) ->
            console.log "onenterstate", arguments
            if self.beforeChange instanceof Function and self.beforeChange(to) is false
                return false

            self.changeContent(event, from, to)
            return true

        # go!
        StateMachine.create stateMachineConfig

        # register popup for possible singleton behavior
        @constructor.registerPopup(@)

    _setAsActive: () ->
        @_setActive(@)
        return @

    show: (callback) ->
        @div.fadeIn(FADE_TIME, callback)
        return @

    hide: (callback) ->
        @div.fadeOut(FADE_TIME, callback)
        return @

    showOverlay: (callback) ->
        @overlay.fadeIn(FADE_TIME, callback)
        return @

    hideOverlay: (callback) ->
        @overlay.fadeOut(FADE_TIME, callback)
        return @

    showLoader: () ->
        @loader.fadeIn(FADE_TIME)
        return @

    hideLoader: () ->
        @loader.fadeOut(FADE_TIME)
        return @

    # ACTION STUFF
    fireAction: (name, params...) ->
        name = name.upper()
        if (action = CLASS.ACTIONS[name])?
            return action.apply(@, params)
        throw new Error("Popup::fireAction: No action with name '#{name}' found!")

    close: (ignoreCallback = false) ->
        if not ignoreCallback and @beforeClose instanceof Function and @beforeClose() is false
            return false

        self = @

        @hide () ->
            self.div.remove()
            return true
        @hideOverlay () ->
            self.overlay.remove()
            return true

        @_popups = @_popups.except @

        if not ignoreCallback
            @onClose?()

        return @

    remove: () ->
        return @close.apply(@, arguments)

    changeContent: (event, from, to) ->
        body = $ """<div class="body" style="width: #{@bodyWidth - @bodyPadding.left - @bodyPadding.right}px;" />"""
        content = @contents[to]

        if not content?
            throw new Error("StatePopup::changeContent: No content given for '#{to}'!")

        if not @bodyWrapper?
            @bodyWrapper = @div.find(".bodyWrapper")

        body.append content

        # animate backwards
        if event is "back"
            @bodyWrapper.prepend(body)
                        .css "margin-left", "-#{@bodyWidth}px"
                        .animate(
                            {
                                "margin-left": "0px"
                            }
                            400
                            "swing"
                            () ->
                                $(@).children().eq(1)
                                    .detach()
                                return true
                        )
        # animate forward
        else if from isnt "none"
            @bodyWrapper
                .append(body)
                .animate(
                    {
                        "margin-left": "-#{@bodyWidth}px"
                    }
                    400
                    "swing"
                    () ->
                        $(@).children().eq(0)
                            .detach()
                        $(@).css("margin-left", "0px")
                        return true
                )


        if not @navigation.hasClass "hidden"
            @navigation.find(".companyBGColorForce").switchClass "companyBGColorForce", "", 200
            @navigation.find(".dot").eq(idx).switchClass "", "companyBGColorForce", 200

        return @

    currentContent: () ->
        return @contents[@current]

    draw: () ->
        if CLASS.MODE is CLASS.MODES.SINGLE and CLASS.getActive()?
            console.warn "Popup::draw: tried to draw more than 1 popup but mode is set to 'single'!"
            return @

        self = @

        if @headline
            headlineDiv = """<div class="header companyBGColor">
                                <div class="headline noselect">#{@headline}</div>
                            </div>"""
        else
            headlineDiv = ""

        @div.empty()
            .append """<div class="content">
                        <div class="close" />
                        <div class="loader" />
                        #{headlineDiv}
                        <div class="bodyWrapper" />
                        <div class="navigation" />
                        <div class="footer" />
                    </div>"""

        # close buutton
        @div.find(".overlay, .close").click () ->
            self.fireAction(self.closeButtonAction)
            return true

        # click => mark as most recently active popup
        @div.mousedown () ->
            self._setAsActive()
            return true

        @navigation = @div.find(".navigation")
        @loader     = @div.find(".loader")
        @footer     = @div.find(".footer")

        # create standard buttons (at bottom)
        buttons = @options.buttons or []

        for button, idx in buttons when button?
            action = null
            # just button key => use default
            if typeof button is "string"
                b = button.upper()
                button = CLASS.BUTTONS[b]
                action = CLASS.ACTIONS[CLASS.BUTTON_ACTIONS[b]]
            # special config given => use that config
            else if button.button? and button.action?
                b = button
                button = CLASS.BUTTONS[b.button.upper()]
                action = CLASS.ACTIONS[b.action.upper()]
            # invalid
            else
                console.warn "Invalid button configuration for Popup!"
                continue

            if action?
                button = $ button
                lastColor = CLASS.BUTTON_COLORS[idx]
                button.css {
                    "background-color": lastColor
                }
                do (action) ->
                    button.click () ->
                        action.call(self)
                        return true
                @footer.append button

        # set footer bg color to last button color
        @footer.css "background-color", lastColor

        self = @

        # linearizable => draw navigation bar
        # if @linearization?
        #     navigation  = @navigation
        #     dot         = $ """<div class="dot companyBorderColor" />"""
        #     for idx in [0...@linearization.length]
        #         do (idx) ->
        #             navigation.append dot.clone().attr("data-state-idx", idx).click () ->
        #                 prevSelectedDot = $(@).siblings(".companyBGColorForce")
        #                 for ...
        #                 if self.change(idx) isnt false
        #                     $(@).switchClass("", "companyBGColorForce", 200)
        #                         .siblings(".companyBGColorForce")
        #                         .switchClass("companyBGColorForce", "", 200)
        #                 return true
        #     # highlight first nav dot
        #     navigation.find(".dot").eq(0).addClass("companyBGColorForce")

        @navigation.addClass "hidden"

        @init()

        # draw only initial content and pre- or append contents as needed (depending on event)
        content = @contents[@current]

        if not content?
            throw new Error("StatePopup::draw: No content found for '#{@current}'!")

        body = $ """<div class="body" style="width: #{@bodyWidth - @bodyPadding.left - @bodyPadding.right}px;" />"""
        body.append content
        @bodyWrapper.append body

        if CLASS.MODE is CLASS.MODES.MANY
            @div
                .draggable {
                    handle: ".header"
                }
                .addClass "draggable"
        else if CLASS.MODE is CLASS.MODES.SINGLE
            $(document.body).append @overlay.click () ->
                self.fireAction("cancel")
                return true

        $(document.body).append @div
        @_setAsActive()

        return @

    # EVENT (STATE MACHINE) STUFF
    # this might seem pointless but implicit function calls might appear weird (and here we have better error reporting)
    fireEvent: (name, params...) ->
        if @[name] instanceof Function
            @[name](params...)
            return @
        console.warn "StateStatePopup::fireEvent: There is no event called '#{name}'! Use onFailure() to catch that!"
        @onFailure?(name)
        return @

    # ACTION STUFF
    next: () ->
        if @beforeNext instanceof Function and @beforeNext() is false
            return false

        foundEvents = []
        # ignore "back" because we're looking for next contents here!
        for event in @stateMachineConfig.events when event.from is @current and event.name isnt "back"
            foundEvents.push event

        if foundEvents.length is 1
            @fireEvent(foundEvents.first.name)
            return @

        if foundEvents.length is 0
            console.warn "StatePopup::next: There is no event for '#{@current}'! Can't go any further! Use onFailure() to catch that!"
            @onFailure?("next")
            return @

        console.warn "StatePopup::next: More than 1 event for '#{@current}': [#{event.name for event in foundEvents}]! Can't decide where to go! Use onFailure() to catch that!"
        @onFailure?("next")
        return @

    prev: () ->
        if @beforePrev instanceof Function and @beforePrev() is false
            return false
        try
            @back()
            return @
        catch e
            console.warn "StatePopup::prev: Cannot go to 'prev' because no back route was defined! Define it with '{ name: 'back', from: 'prevState', to: 'returnState' }' ;) Use onFailure() to catch that!"
            console.warn e
            @onFailure?("prev")
            return @

    change: (targetState) ->
        if @beforeChange instanceof Function and @beforeChange(idx) is false
            return false

        for event in @stateMachineConfig.events when event.from is @current and event.to is targetState
            @fireEvent(event.name)
            if @onChange instanceof Function
                @onChange.call(@, event.from, targetState)
            return @

        console.warn "StatePopup::change: Cannot go to '#{targetState}' from '#{@current}'! Use onFailure() to catch that!"
        @onFailure?("change")
        return @

# extends StateMachineBox for different class/instance naming
class SMB extends StateMachineBox
    # constructor: () ->
