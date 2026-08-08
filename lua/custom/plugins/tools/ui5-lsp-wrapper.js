#!/usr/bin/env node
// Bridge cho @ui5-language-assistant/language-server sang Neovim (xem ui5.lua).
// Package này KHÔNG có CLI/bin — chỉ export module để VSCode spawn qua Node IPC
// (xem packages/vscode-ui5-language-assistant/src/extension.ts: TransportKind.ipc).
// server.js bên trong gọi createConnection(ProposedFeatures.all), tự nhận diện transport
// qua process.argv ('--stdio'/'--node-ipc'/'--socket'), nên chạy trực tiếp bằng node kèm
// '--stdio' vẫn hoạt động bình thường dù không đi qua đường IPC như VSCode.
// Yêu cầu: npm install -g @ui5-language-assistant/language-server (Node.js >= 22)
'use strict'

const { execSync } = require('child_process')
const path = require('path')

let globalRoot
try {
  globalRoot = execSync('npm root -g', { encoding: 'utf8' }).trim()
} catch (err) {
  process.stderr.write('ui5-lsp-wrapper: "npm root -g" thất bại: ' + err.message + '\n')
  process.exit(1)
}

let pkgMain
try {
  pkgMain = require.resolve(path.join(globalRoot, '@ui5-language-assistant', 'language-server'))
} catch (err) {
  process.stderr.write(
    'ui5-lsp-wrapper: không tìm thấy @ui5-language-assistant/language-server.\n' +
      'Cài bằng: npm install -g @ui5-language-assistant/language-server\n'
  )
  process.exit(1)
}

require(path.join(path.dirname(pkgMain), 'server.js'))
