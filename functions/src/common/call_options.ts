import { CallableOptions } from 'firebase-functions/https';

import { region } from './app';

/** Опции вызываемых функций: регион и обязательный App Check; эмулятор токены App Check не выдаёт. */
export const callOptions: CallableOptions = {
  region,
  enforceAppCheck: process.env.FUNCTIONS_EMULATOR !== 'true',
};
