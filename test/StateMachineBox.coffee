describe "StateMachineBox", () ->

    it "should work", () ->

        renderOptions =
            title:      false
            format:     ""
            dateFormat: null

        # CONTENT FOR "chooseExportFormat"
        formats = ["png", "csv"]
        formatOptions = $ """<div>Exportformat wählen:</div>
                            #{("""<div class="formatOption">#{format.toUpperCase()}</div>""" for format in formats).join("\n")}"""

        formatOptions.filter(".formatOption").eq(0).click () ->
            elem = $ @
            renderOptions.format = formats[0]
            popup.fireEvent("png")
            return true
        formatOptions.filter(".formatOption").eq(1).click () ->
            elem = $ @
            renderOptions.format = formats[1]
            popup.fireEvent("csv")
            return true

        # CONTENT FOR "chooseExportTitle"
        options = [true, false]
        titleOptions = $ """<div>Sollen Titel und Untertitel mit exportiert werden?<br />
                            (Falls beide leer sind, wird diese Einstellung ignoriert)</div>
                            <div class="titleOption">Ja</div>
                            <div class="titleOption selected">Nein</div>"""
        titleOptions.filter(".titleOption").each (idx, elem) ->
            elem = $ elem
            return elem.click () ->
                renderOptions.title = options[idx]
                popup.fireEvent("exportTitleOptionChosen")
                return true

        # CONTENT FOR "chooseDateFormat"
        # chosenDateFormat    = "auto"
        dateFormats         = ["auto"]
        dateFormatOptions   = $ """<div>Datumsformat wählen:</div>
                                   <div class="dateFormatOption selected">AUTO</div>
                                   <div class="dateFormatLabel">
                                       <span class="hidden">Beispiel:</span>
                                       <span>abhängig vom Zeitintervall im Favoriten</span>
                                   </div>
                                   <div class="dateFormat ok">OK</div>"""
        dateFormatOptions.filter(".dateFormatOption").each (idx, elem) ->
            elem = $ elem
            return elem.click () ->
                # popup.fireEvent(format)
                return true
        dateFormatOptions.filter(".ok").click () ->
            popup.fireEvent("formatChosen")
            return true

        # CONTENT FOR "chooseStartPNGExport" and "chooseStartCSVExport"
        startOptions = $ """<div>Export starten?</div>
                            <div class="startOption">OK</div>
                            <div class="startOption">Abbrechen</div>"""
        startOptions.filter(".startOption").eq(0).click () ->
            return popup.close()
        startOptions.filter(".startOption").eq(1).click () ->
            return popup.fireAction("cancel")

        popupStateMachine =
            events: [
                # initial content
                { name: "init", from: "none", to: "chooseExportFormat", content: formatOptions }
                # choose format
                { name: "png",  from: "chooseExportFormat", to: "chooseExportTitle", content: titleOptions }
                { name: "csv",  from: "chooseExportFormat", to: "chooseDateFormat", content: dateFormatOptions }
                { name: "back", from: "chooseExportFormat", to: "chooseExportFormat" } # enable going back (must be "back")
                # export title? (in PNG branch)
                { name: "exportTitleOptionChosen",  from: "chooseExportTitle", to: "chooseStartPNGExport", content: startOptions }
                { name: "back",                     from: "chooseExportTitle", to: "chooseExportFormat" }
                # choose date format (in CSV branch)
                { name: "formatChosen", from: "chooseDateFormat", to: "chooseStartCSVExport", content: startOptions }
                { name: "back",         from: "chooseDateFormat", to: "chooseExportFormat" }
                # start export? (in PNG branch)
                { name: "true",  from: "chooseStartPNGExport", to: "close" } # "close" = reserved state (-> action) of the popup
                { name: "false", from: "chooseStartPNGExport", to: "cancel" } # "cancel" = reserved state (-> action) of the popup
                { name: "back",  from: "chooseStartPNGExport", to: "chooseExportTitle" }
                # start export? (in CSV branch)
                { name: "true",  from: "chooseStartCSVExport", to: "close" }
                { name: "false", from: "chooseStartCSVExport", to: "cancel" }
                { name: "back",  from: "chooseStartCSVExport", to: "chooseDateFormat" }
            ]

        popup = new StateMachineBox(popupStateMachine, "Exporteinstellungen", {
            buttons: ["cancel", "next", "prev"]
            closeButtonAction: "cancel"
            width: "500px"
            height: "350px"
            onClose: () ->
                startRendering(favIds, renderOptions, folderName)
            onFailure: (event) ->
                currentState = @current
                if event is "next"
                    if currentState is "chooseExportFormat"
                        # no file format chosen yet => highlight both buttons
                        if renderOptions.format not in formats
                            content = popup.currentContent()
                            orgColor = content.eq(0).css("color")
                        # something has previously been selected => go that route
                        else
                            popup.fireEvent renderOptions.format
                        return false
                    # valid options and clicking "next" on last content => also start export
                    if currentState in ["chooseStartPNGExport", "chooseStartCSVExport"]
                        popup.close()
                        return false
                return true
        })
        popup.draw()

        # check if we get here
        expect(true).toBe(true)
