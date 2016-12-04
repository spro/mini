React = require 'react'
ReactDOM = require 'react-dom'
{ipcRenderer} = require 'electron'
fs = require 'fs'

ipcRenderer.send 'ready', true

App = React.createClass
    getInitialState: ->
        body: ''
        opacity: 100
        saved: true
        inverted: false
        editing_filename: false
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

        ipcRenderer.on 'file-save', =>
            fs.writeFileSync @state.filename, @state.body
            @setState {saved: true}

        ipcRenderer.on 'file-invert', =>
            @setState {inverted: !@state.inverted}

    changeBody: (e) ->
        @setState {body: e.target.value, saved: false}

    changeOpacity: (e) ->
        @setState {opacity: e.target.value}

    editFilename: ->
        @setState {editing_filename: true}, => @refs.filename.focus()

    changeFilename: (e) ->
        @setState {filename: e.target.value}

    onKeyDown: (e) ->
        if e.key == 'Enter'
            @setState {editing_filename: false, saved: false}

    render: ->
        <div className={'container' + if @state.inverted then ' inverted' else ''} style={opacity: @state.opacity / 100}>
            <div className='title-bar'>
                {if @state.editing_filename
                    <input ref='filename' type='text' className='filename' onChange=@changeFilename onKeyDown=@onKeyDown value=@state.filename />
                else
                    <div className='filename' onDoubleClick=@editFilename>{@state.filename or 'untitled'} {if @state.saved then '' else '*'}</div>
                }
                <input type='range' min=40 max=100 value=@state.opacity onChange=@changeOpacity />
            </div>
            <textarea value=@state.body onChange=@changeBody></textarea>
        </div>

ReactDOM.render <App />, document.getElementById 'app'
