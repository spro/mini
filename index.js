const {app, shell, dialog, ipcMain, BrowserWindow, Menu, MenuItem} = require('electron')
const path = require('path')
const url = require('url')
const defaultMenu = require('electron-default-menu');

// Keep a global reference of the window object, if you don't, the window will
// be closed automatically when the JavaScript object is garbage collected.
let wins = [];

function createWindow(filename, x, y) {
  // Create the browser window.
  let win = new BrowserWindow({x: x, y: y, width: 500, height: 300, titleBarStyle: 'hidden', transparent: true, show: false})
  wins.push(win);

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
    wins = wins.filter((w) => w != win);
  })

  win.on('ready-to-show', () => {
      win.webContents.send('file-open', filename);
      win.show();
  });

}

// ipcMain.once('ready', (event) => {
//   event.sender.send('open-file', filename);
// });

function setupMenu() {

  // Keyboard shortcuts

  function open() {
      openOpenDialog(null);
      // BrowserWindow.getFocusedWindow().webContents.send('file-save');
  }

  function save() {
      BrowserWindow.getFocusedWindow().webContents.send('file-save');
  }

  function saveAs() {
      openSaveDialog(BrowserWindow.getFocusedWindow())
  }

  function invert() {
      BrowserWindow.getFocusedWindow().webContents.send('file-invert');
  }

    const menu = defaultMenu(app, shell);
    menu.splice(1, 0, {
        label: 'File',
        submenu: [
            {click: open, label: 'Open', accelerator: 'Cmd+O'},
            {click: save, label: 'Save', accelerator: 'Cmd+S'},
            {click: saveAs, label: 'Save As...', accelerator: 'Cmd+Shift+S'},
            {click: invert, label: 'invert', accelerator: 'Cmd+Shift+I'},
        ]
    });
    Menu.setApplicationMenu(Menu.buildFromTemplate(menu));
}

function onOpened(_win, filename) {
    createWindow(filename.toString(), 1700, -100);
}

function onSaved(_win, filename) {
    _win.webContents.send('file-saveas', filename.toString())
}

function openOpenDialog(_win) {
    dialog.showOpenDialog(_win, {
        defaultPath: '/Users/sean/Desktop',
        properties: ['openFile'],
        filters: [{ name: 'Text', extensions: ['txt', 'js', 'md']}]
    }, onOpened.bind(null, _win));
}

function openSaveDialog(_win) {
    dialog.showSaveDialog(_win, {
        defaultPath: '/Users/sean/Desktop',
        filters: [{ name: 'Text', extensions: ['txt', 'js', 'md']}]
    }, onSaved.bind(null, _win));
}

// This method will be called when Electron has finished
// initialization and is ready to create browser windows.
// Some APIs can only be used after this event occurs.
app.on('ready', () => {
    setupMenu();
    // openOpenDialog();
    createWindow(null, 1600, -50);
});

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
  if (wins.length == 0) {
    createWindow(null, 1600, -50);
  }
})

// app.on('open-file', (filename) => {
//     createWindow(1700, -100);
// });
