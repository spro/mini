const {app, shell, BrowserWindow, Menu, MenuItem} = require('electron')
const path = require('path')
const url = require('url')
const defaultMenu = require('electron-default-menu');

// Keep a global reference of the window object, if you don't, the window will
// be closed automatically when the JavaScript object is garbage collected.
let win

function createWindow () {
  // Create the browser window.
  win = new BrowserWindow({x: 1600, y: -50, width: 300, height: 300, titleBarStyle: 'hidden', transparent: true})

  // and load the app.html of the app.
  win.loadURL(url.format({
    pathname: path.join(__dirname, 'app.html'),
    protocol: 'file:',
    slashes: true
  }))

  // Open the DevTools.
  // win.webContents.openDevTools()

  // Emitted when the window is closed.
  win.on('closed', () => {
    // Dereference the window object, usually you would store windows
    // in an array if your app supports multi windows, this is the time
    // when you should delete the corresponding element.
    win = null
  })

  // Keyboard shortcuts

  function save() {
      BrowserWindow.getFocusedWindow().webContents.send('file-save');
  }

  function invert() {
      BrowserWindow.getFocusedWindow().webContents.send('file-invert');
  }

    const menu = defaultMenu(app, shell);
    menu.splice(1, 0, {
        label: 'File',
        submenu: [
            {click: save, label: 'Save', accelerator: 'Cmd+S'},
            {click: invert, label: 'invert', accelerator: 'Cmd+Shift+I'},
        ]
    });
    Menu.setApplicationMenu(Menu.buildFromTemplate(menu));
}


// This method will be called when Electron has finished
// initialization and is ready to create browser windows.
// Some APIs can only be used after this event occurs.
app.on('ready', createWindow)

// Quit when all windows are closed.
app.on('window-all-closed', () => {
  // On macOS it is common for applications and their menu bar
  // to stay active until the user quits explicitly with Cmd + Q
  if (process.platform !== 'darwin') {
    app.quit()
  }
})

app.on('activate', () => {
  // On macOS it's common to re-create a window in the app when the
  // dock icon is clicked and there are no other windows open.
  if (win === null) {
    createWindow()
  }
})

