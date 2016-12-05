React = require 'react'
ReactDOM = require 'react-dom'
electron = require 'electron'
{ipcRenderer} = electron
fs = require 'fs'
Kefir = require 'kefir'
KefirBus = require 'kefir-bus'

ipcRenderer.send 'ready', true

getWindowWidth = ->
    electron.remote.BrowserWindow.getFocusedWindow()?.getSize()[0] or 300

_window_width$ = KefirBus()

changeWindowWidth = (e) ->
    _window_width$.emit true

window_width$ = _window_width$.debounce(100).map(getWindowWidth)

window.addEventListener('resize', changeWindowWidth)

App = React.createClass
    getInitialState: ->
        body: ''
        opacity: 90
        font_size: 12
        width: 300
        window_width: getWindowWidth()
        saved: true
        inverted: false
        filename: null

    readFile: ->
        if @state.filename?
            try
                @setState {body: fs.readFileSync @state.filename, 'utf8'}
            catch e
                alert "Can't open file #{@state.filename}: #{e}"

    componentDidMount: ->
        @readFile()

        ipcRenderer.on 'file-open', (event, filename) =>
            @setState {filename}, @readFile.bind(@)

        ipcRenderer.on 'file-saveas', (event, filename) =>
            @setState {filename}, =>
                fs.writeFileSync @state.filename, @state.body
                @setState {saved: true}

        ipcRenderer.on 'file-save', =>
            fs.writeFileSync @state.filename, @state.body
            @setState {saved: true}

        ipcRenderer.on 'file-invert', @invert

        window_width$.onValue @setWindowWidth

        changeWindowWidth()

    invert: ->
        @setState {inverted: !@state.inverted}

    setWindowWidth: (window_width) -> @setState {window_width}

    changeBody: (e) ->
        @setState {body: e.target.value, saved: false}

    openRange: (range) -> => @setState {range}

    closeRange: -> @setState {range: null}

    changeRange: (range) -> (e) =>
        change = {}
        change[range] = e.target.value
        @setState change

    renderRange: (range) ->
        {min, max} = ranges[range]
        if typeof min == 'function' then min = min(@state)
        if typeof max == 'function' then max = max(@state)
        <input type='range' min={min} max={max} value={@state[range]} onChange={@changeRange(range)} />

    render: ->
        <div className={'container' + if @state.inverted then ' inverted' else ''} style={opacity: @state.opacity / 100}>
            <div className='title-bar'>
                <div className='filename'>{@state.filename or 'untitled'} {if @state.saved then '' else '*'}</div>
                {if @state.window_width > 300
                    if @state.range
                        <div className='ranges'>
                            {@renderRange @state.range}
                            <a onClick=@closeRange><i className='fa fa-times-circle' /></a>
                        </div>
                    else
                        <div className='ranges'>
                            <a onClick=@openRange('font_size')><i className='fa fa-font' /></a>
                            <a onClick=@openRange('opacity')><i className='fa fa-adjust' /></a>
                            <a onClick=@openRange('width')><i className='fa fa-compress' /></a>
                            <a onClick=@invert><i className={'fa fa-' + if @state.inverted then 'circle-o' else 'circle'} /></a>
                        </div>
                }
            </div>
            <textarea value=@state.body onChange=@changeBody style={maxWidth: @state.width + 'px', fontSize: @state.font_size}></textarea>
        </div>

ranges = {
    width: {min: 300, max: ({window_width}) -> window_width}
    opacity: {min: 40, max: 100}
    font_size: {min: 5, max: 100}
}


ReactDOM.render <App />, document.getElementById 'app'
