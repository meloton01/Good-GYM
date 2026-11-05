import { initializeApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import { getStorage } from 'firebase-admin/storage';

initializeApp();

/** Регион функций: ближе к аудитории приложения; клиент вызывает функции в нём же. */
export const region = 'europe-west1';

/** Firestore с правами администратора. */
export const db = getFirestore();

/** Бакет Storage по умолчанию. */
export const bucket = () => getStorage().bucket();
