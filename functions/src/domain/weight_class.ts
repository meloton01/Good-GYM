/** Пол для весовых категорий. */
export type Sex = 'male' | 'female';

/** Верхние границы категорий IPF, кг. */
const limits: Record<Sex, readonly number[]> = {
  male: [59, 66, 74, 83, 93, 105, 120],
  female: [47, 52, 57, 63, 69, 76, 84],
};

const prefix: Record<Sex, string> = { male: 'm', female: 'f' };

/** Проверяет значение пола. */
export function isSex(value: unknown): value is Sex {
  return value === 'male' || value === 'female';
}

/** Категория по весу тела: «m83» до 83 кг включительно, «m120plus» тяжелее последней границы. */
export function weightClassFor(sex: Sex, bodyWeightKg: number): string {
  const bounds = limits[sex];
  const upper = bounds.find((bound) => bodyWeightKg <= bound);
  const last = bounds[bounds.length - 1];
  return upper === undefined ? `${prefix[sex]}${last}plus` : `${prefix[sex]}${upper}`;
}
