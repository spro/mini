React = require 'react'
ReactDOM = require 'react-dom'
{ipcRenderer} = require 'electron'
fs = require 'fs'

App = React.createClass
    getInitialState: ->
        body: ''
        opacity: 100
        saved: true
        inverted: false

    componentDidMount: ->
        try
            @setState {body: fs.readFileSync '/Users/sean/Desktop/title.txt', 'utf8'}
        catch e
            console.log 'no file'

        ipcRenderer.on 'file-save', =>
            fs.writeFileSync '/Users/sean/Desktop/title.txt', @state.body
            @setState {saved: true}

        ipcRenderer.on 'file-invert', =>
            @setState {inverted: !@state.inverted}

    changeBody: (e) ->
        @setState {body: e.target.value, saved: false}

    changeOpacity: (e) ->
        @setState {opacity: e.target.value}

    editFilename: ->
        alert 'ok?'

    render: ->
        <div className={'container' + if @state.inverted then ' inverted' else ''} style={opacity: @state.opacity / 100}>
            <div className='title-bar'>
                <div className='title' onDoubleClick=@editFilename>title.txt {if @state.saved then '' else '*'}</div>
                <input type='range' min=20 max=100 value=@state.opacity onChange=@changeOpacity />
            </div>
            <textarea value=@state.body onChange=@changeBody></textarea>
        </div>

ReactDOM.render <App />, document.getElementById 'app'
