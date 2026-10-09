const storageKey = 'nutriday-v1';
const defaultGoals = { calories: 2000, protein: 100, carbs: 250, fat: 70, fiber: 28, water: 8 };
const sampleMeals = [
  { name: 'Greek yogurt with berries', meal: 'Breakfast', calories: 280, protein: 20, carbs: 34, fat: 6, fiber: 5, emoji: '🥣' },
  { name: 'Avocado toast', meal: 'Breakfast', calories: 320, protein: 12, carbs: 38, fat: 14, fiber: 8, emoji: '🥑' },
  { name: 'Grilled chicken salad', meal: 'Lunch', calories: 480, protein: 38, carbs: 32, fat: 21, fiber: 7, emoji: '🥗' },
  { name: 'Apple', meal: 'Snack', calories: 104, protein: 1, carbs: 28, fat: 0, fiber: 5, emoji: '🍎' }
];
const macroDefinitions = [
  { label: 'Protein', key: 'protein', unit: 'g', icon: '◌' },
  { label: 'Carbs', key: 'carbs', unit: 'g', icon: '✳' },
  { label: 'Fat', key: 'fat', unit: 'g', icon: '⌁' },
  { label: 'Fiber', key: 'fiber', unit: 'g', icon: '◍' }
];
const $ = (selector) => document.querySelector(selector);
const $$ = (selector) => [...document.querySelectorAll(selector)];

function dateKey(date) {
  return [date.getFullYear(), String(date.getMonth() + 1).padStart(2, '0'), String(date.getDate()).padStart(2, '0')].join('-');
}
function makeDay(water, meals) { return { water: water || 0, meals: meals || [] }; }
function readState() {
  try {
    const saved = JSON.parse(localStorage.getItem(storageKey) || '{}');
    const today = dateKey(new Date());
    const days = saved.days || { [today]: makeDay(saved.water ?? 5, saved.meals || sampleMeals) };
    return { goals: { ...defaultGoals, ...(saved.goals || {}) }, days };
  } catch {
    return { goals: { ...defaultGoals }, days: { [dateKey(new Date())]: makeDay(5, sampleMeals) } };
  }
}
const state = readState();
let selectedDate = new Date();
let toastTimer;
function currentDay() {
  const key = dateKey(selectedDate);
  if (!state.days[key]) state.days[key] = makeDay(0, []);
  return state.days[key];
}
function save() { localStorage.setItem(storageKey, JSON.stringify(state)); }
function totals(meals) {
  return meals.reduce((result, meal) => {
    ['calories', 'protein', 'carbs', 'fat', 'fiber'].forEach((key) => {
      result[key] = (result[key] || 0) + (Number(meal[key]) || 0);
    });
    return result;
  }, {});
}
function formatNumber(value) { return Math.round(value || 0).toLocaleString(); }
function escapeHtml(value) {
  return String(value).replace(/[&<>"']/g, (character) => ({
    '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'
  })[character]);
}
function showToast(message) {
  const toast = $('#toast');
  toast.textContent = message;
  toast.classList.add('show');
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => toast.classList.remove('show'), 2400);
}
function updateDateLabel() {
  const isToday = dateKey(selectedDate) === dateKey(new Date());
  const formatted = selectedDate.toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric' });
  $('#dateLabel').textContent = isToday
    ? 'Today, ' + selectedDate.toLocaleDateString('en-US', { month: 'long', day: 'numeric' })
    : selectedDate.toLocaleDateString('en-US', { weekday: 'short', month: 'short', day: 'numeric' });
  $('#todayDateLabel').textContent = formatted.toUpperCase();
  $('#waterGoalLabel').textContent = ' / ' + state.goals.water + ' glasses';
  $('#prevDay').setAttribute('aria-label', 'Previous day, ' + formatted);
  $('#nextDay').setAttribute('aria-label', 'Next day, ' + formatted);
}
function render() {
  const day = currentDay();
  const goal = state.goals;
  const amount = totals(day.meals);
  const calories = amount.calories || 0;
  const calorieProgress = Math.min(100, calories / goal.calories * 100);

  updateDateLabel();
  $('#caloriesValue').textContent = formatNumber(calories);
  $('#caloriesEatenLabel').textContent = formatNumber(calories);
  $('#caloriesGoalLabel').textContent = formatNumber(goal.calories);
  $('#caloriesLeft').innerHTML = formatNumber(Math.max(0, goal.calories - calories)) + ' <small>kcal</small>';
  $('#caloriePercent').textContent = Math.round(calorieProgress) + '% of goal';
  $('#calorieStatus').textContent = calories >= goal.calories ? 'Goal reached' : 'In progress';
  $('#calorieRing').style.strokeDashoffset = 477.5 * (1 - calorieProgress / 100);
  $('#waterValue').textContent = day.water;
  $('#waterGlasses').innerHTML = Array.from({ length: Math.min(goal.water, 20) }, (_, index) =>
    '<span class="glass ' + (index < day.water ? 'full' : '') + '" aria-label="Glass ' + (index + 1) + (index < day.water ? ', logged' : ', not logged') + '"></span>'
  ).join('');

  $('#macroGrid').innerHTML = macroDefinitions.map((macro) => {
    const value = amount[macro.key] || 0;
    const target = goal[macro.key] || 0;
    const progress = target ? Math.min(100, value / target * 100) : 0;
    return '<article class="macro-card"><div class="macro-top"><span class="macro-icon" aria-hidden="true">' + macro.icon +
      '</span><span class="eyebrow">' + Math.round(progress) + '%</span></div><div class="macro-name">' + macro.label +
      '</div><div class="macro-val">' + formatNumber(value) + ' <small>' + macro.unit + '</small></div><div class="macro-target">of ' +
      formatNumber(target) + ' ' + macro.unit + ' goal</div><div class="bar-track" role="progressbar" aria-label="' + macro.label +
      '" aria-valuenow="' + Math.round(progress) + '" aria-valuemin="0" aria-valuemax="100"><div class="bar-fill" style="width:' +
      progress + '%"></div></div></article>';
  }).join('');

  $('#mealList').innerHTML = day.meals.length ? day.meals.map((meal, index) =>
    '<div class="meal-row"><span class="meal-emoji" aria-hidden="true">' + (meal.emoji || '🍽️') +
    '</span><div><div class="meal-name">' + escapeHtml(meal.name) + '</div><div class="meal-meta">' +
    escapeHtml(meal.meal) + ' · ' + formatNumber(meal.protein) + 'g protein</div></div><span class="meal-cal">' +
    formatNumber(meal.calories) + ' <small>kcal</small></span><button class="remove-meal" type="button" data-remove="' +
    index + '" aria-label="Remove ' + escapeHtml(meal.name) + '" title="Remove food">×</button></div>'
  ).join('') : '<div class="empty-meals">No food logged for this day yet. Add a meal to get started.</div>';

  $('#insightCards').innerHTML =
    '<article class="card insight-stat"><div class="eyebrow">ENERGY</div><strong>' + formatNumber(calories) +
    ' <small>kcal</small></strong><p>' + Math.round(calorieProgress) + '% of your daily energy goal</p></article>' +
    '<article class="card insight-stat"><div class="eyebrow">PROTEIN</div><strong>' + formatNumber(amount.protein) +
    ' <small>g</small></strong><p>' + formatNumber(Math.max(0, goal.protein - (amount.protein || 0))) +
    'g to your daily goal</p></article><article class="card insight-stat"><div class="eyebrow">WATER</div><strong>' +
    day.water + ' <small>glasses</small></strong><p>' + Math.max(0, goal.water - day.water) + ' more to reach your goal</p></article>';

  const breakdown = [{ label: 'Calories', key: 'calories', unit: 'kcal' }, ...macroDefinitions.map((item) => ({ ...item }))];
  $('#insightBars').innerHTML = breakdown.map((item) => {
    const value = amount[item.key] || 0;
    const target = goal[item.key] || 0;
    const progress = target ? Math.min(100, value / target * 100) : 0;
    return '<div class="insight-line"><span>' + item.label + '</span><div class="bar-track" role="progressbar" aria-label="' +
      item.label + '" aria-valuenow="' + Math.round(progress) + '" aria-valuemin="0" aria-valuemax="100"><div class="bar-fill" style="width:' +
      progress + '%"></div></div><b>' + formatNumber(value) + ' / ' + formatNumber(target) + ' ' + item.unit + '</b></div>';
  }).join('');

  $('#goalCalories').value = goal.calories;
  $('#goalProtein').value = goal.protein;
  $('#goalCarbs').value = goal.carbs;
  $('#goalFat').value = goal.fat;
  $('#goalWater').value = goal.water;
}
function navigateTo(page) {
  $$('.page').forEach((section) => section.classList.toggle('active', section.id === page + 'Page'));
  $$('[data-page]').forEach((button) => {
    const active = button.dataset.page === page;
    button.classList.toggle('active', active);
    button.setAttribute('aria-current', active ? 'page' : 'false');
  });
  window.scrollTo({ top: 0, behavior: 'smooth' });
}
$$('[data-page]').forEach((button) => button.addEventListener('click', () => navigateTo(button.dataset.page)));
$$('[data-go]').forEach((button) => button.addEventListener('click', () => navigateTo(button.dataset.go)));
$('#profileShortcut').addEventListener('click', () => navigateTo('profile'));
$('#prevDay').addEventListener('click', () => { selectedDate.setDate(selectedDate.getDate() - 1); render(); });
$('#nextDay').addEventListener('click', () => { selectedDate.setDate(selectedDate.getDate() + 1); render(); });
$('#addWater').addEventListener('click', () => {
  const day = currentDay();
  if (day.water >= state.goals.water) return showToast('You’ve reached your water goal for this day.');
  day.water += 1;
  save();
  render();
  showToast('Water logged.');
});
const foodDialog = $('#foodDialog');
$('#addFoodTop').addEventListener('click', () => foodDialog.showModal());
$('#addFoodMeal').addEventListener('click', () => foodDialog.showModal());
$('#foodForm').addEventListener('submit', (event) => {
  if (event.submitter && event.submitter.value === 'cancel') return;
  event.preventDefault();
  const form = new FormData(event.currentTarget);
  const mealType = form.get('meal');
  const emojiByMeal = { Breakfast: '🍳', Lunch: '🥗', Dinner: '🍲', Snack: '🍎' };
  currentDay().meals.push({
    name: String(form.get('name')).trim(),
    meal: mealType,
    calories: Number(form.get('calories')),
    protein: Number(form.get('protein')) || 0,
    carbs: Number(form.get('carbs')) || 0,
    fat: Number(form.get('fat')) || 0,
    fiber: Number(form.get('fiber')) || 0,
    emoji: emojiByMeal[mealType] || '🍽️'
  });
  save();
  render();
  event.currentTarget.reset();
  foodDialog.close();
  showToast('Added to your food journal.');
});
$('#mealList').addEventListener('click', (event) => {
  const removeButton = event.target.closest('[data-remove]');
  if (!removeButton) return;
  currentDay().meals.splice(Number(removeButton.dataset.remove), 1);
  save();
  render();
  showToast('Food removed from your journal.');
});
$('#saveGoals').addEventListener('click', () => {
  ['calories', 'protein', 'carbs', 'fat', 'water'].forEach((key) => {
    const input = $('#goal' + key[0].toUpperCase() + key.slice(1));
    const value = Number(input.value);
    if (value > 0) state.goals[key] = value;
  });
  save();
  render();
  showToast('Your goals have been updated.');
});
render();