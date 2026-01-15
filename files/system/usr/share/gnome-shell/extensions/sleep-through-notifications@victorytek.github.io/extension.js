import GObject from 'gi://GObject';
import {Extension} from 'resource:///org/gnome/shell/extensions/extension.js';
import {ScreenShield} from 'resource:///org/gnome/shell/ui/screenShield.js';

export default class SleepThroughNotifications extends Extension {
  enable() {
    const _ensureUnlockDialog = this._ensureUnlockDialog =
      ScreenShield.prototype._ensureUnlockDialog;

    ScreenShield.prototype._ensureUnlockDialog = function () {
      const result = _ensureUnlockDialog.apply(this, arguments);
      if (result) {
        GObject.signal_handlers_block_matched(this._dialog, {
          signalId: 'wake-up-screen',
        });
      }
      return result;
    }
  }

  disable() {
    if (this._ensureUnlockDialog) {
      ScreenShield.prototype._ensureUnlockDialog = this._ensureUnlockDialog;
      this._ensureUnlockDialog = null;
    }
  }
}
