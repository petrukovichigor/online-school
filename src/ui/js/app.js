// Интерфейс только показывает данные. Вся логика и SQL — в Python (src/api.py).
// Если окно открыто без pywebview, используются демо-данные.
const demo = {
  categories: ['Программирование', 'Языки', 'Дизайн', 'Маркетинг', 'Бизнес'],
  courses: [
    {id: 1, title: 'Python с нуля', category: 'Программирование', teacher: 'Анна Ковалёва', price: 120, description: 'Основы языка, функции, работа с файлами и базами данных.'},
    {id: 2, title: 'Английский для IT', category: 'Языки', teacher: 'Иван Сидоров', price: 90, description: 'Лексика и разговорная практика для специалистов в сфере IT.'},
    {id: 3, title: 'Основы UX/UI', category: 'Дизайн', teacher: 'Мария Лис', price: 110, description: 'От исследования пользователей до прототипа в Figma.'}
  ],
  subs: {1: 'active', 2: 'pending'},
  lessons: [
    {id: 1, position: 1, title: 'Установка и первая программа', video_url: 'https://www.youtube.com/watch?v=rfscVS0vtbw'},
    {id: 2, position: 2, title: 'Переменные и типы данных', video_url: 'https://www.youtube.com/watch?v=rfscVS0vtbw'}
  ],
  homeworks: {1: {description: 'Напишите программу, которая выводит ваше имя и возраст.', file_url: null, grade: null},
              2: {description: 'Решите три задачи на типы данных.', file_url: 'https://drive.google.com/demo', grade: 9}}
};

const api = async (name, ...a) =>
  (window.pywebview && pywebview.api && pywebview.api[name]) ? pywebview.api[name](...a) : demoCall(name, ...a);

async function demoCall(name, ...a) {
  if (name === 'get_categories') return demo.categories;
  if (name === 'get_courses') return demo.courses;
  if (name === 'get_subscriptions') return demo.subs;
  if (name === 'get_lessons') return demo.lessons;
  if (name === 'get_homework') return demo.homeworks[a[0]];
  if (name === 'buy_course') { demo.subs[a[0]] = 'pending'; return true; }
  if (name === 'pay_course') { demo.subs[a[0]] = 'active'; return true; }
  if (name === 'submit_homework') { demo.homeworks[a[0]].file_url = a[1]; return true; }
  return null;
}

const $ = s => document.querySelector(s);
const state = {cat: null, course: null, lesson: null, subs: {}};
const statusText = {pending: 'Ждёт оплаты', active: 'Доступен', cancelled: 'Отменён'};

function go(id) {
  document.querySelectorAll('.screen').forEach(s => s.classList.toggle('on', s.id === id));
  document.querySelectorAll('.nav').forEach(n => n.classList.toggle('on', n.dataset.go === id));
  if (id === 'catalog') renderCatalog();
  if (id === 'my') renderMy();
  if (id === 'grades') renderGrades();
}
function toast(t) { const el = $('#toast'); el.textContent = t; el.classList.add('on'); setTimeout(() => el.classList.remove('on'), 2200); }
function embed(u) { const m = u.match(/(?:v=|youtu\.be\/)([\w-]{11})/); return m ? 'https://www.youtube.com/embed/' + m[1] : ''; }

function card(c, onclick, extra = '') {
  const b = document.createElement('button');
  b.className = 'course';
  b.innerHTML = `<div class="cover">${c.category}</div><div class="cbody"><strong>${c.title}</strong><small>${c.teacher}</small>${extra}</div>`;
  b.onclick = onclick;
  return b;
}

async function renderCatalog() {
  state.subs = await api('get_subscriptions');
  const cats = await api('get_categories');
  $('#chips').innerHTML = '';
  ['Все', ...cats].forEach(c => {
    const b = document.createElement('button');
    b.className = 'chip' + ((state.cat || 'Все') === c ? ' on' : '');
    b.textContent = c;
    b.onclick = () => { state.cat = c === 'Все' ? null : c; renderCatalog(); };
    $('#chips').append(b);
  });
  const courses = (await api('get_courses')).filter(c => !state.cat || c.category === state.cat);
  $('#courseGrid').innerHTML = courses.length ? '' : '<div class="empty">В этой категории пока нет курсов.</div>';
  courses.forEach(c => $('#courseGrid').append(card(c, () => openCourse(c), `<div class="price">${c.price} BYN</div>`)));
}

async function openCourse(c) {
  state.course = c;
  state.subs = await api('get_subscriptions');
  $('#cTitle').textContent = c.title;
  $('#cMeta').textContent = `${c.category}, преподаватель ${c.teacher}`;
  $('#cDesc').textContent = c.description;
  $('#cPrice').textContent = c.price + ' BYN';
  const lessons = await api('get_lessons', c.id);
  $('#cLessons').innerHTML = lessons.map(l => `<li><button disabled><i>${l.position}</i>${l.title}</button></li>`).join('');
  const s = state.subs[c.id], btn = $('#cBuy');
  btn.style.display = 'block';
  btn.className = 'btn';
  if (!s || s === 'cancelled') { $('#cState').textContent = 'Сначала оплата, потом доступ к урокам.'; btn.textContent = 'Купить'; btn.onclick = async () => { await api('buy_course', c.id); toast('Заказ создан, осталось оплатить'); openCourse(c); }; }
  else if (s === 'pending') { $('#cState').innerHTML = '<span class="badge pending">Ждёт оплаты</span>'; btn.textContent = 'Оплатить'; btn.className = 'btn alt'; btn.onclick = async () => { await api('pay_course', c.id); toast('Оплата прошла'); openCourse(c); }; }
  else { $('#cState').innerHTML = '<span class="badge active">Курс оплачен</span>'; btn.textContent = 'Перейти к урокам'; btn.onclick = () => openLessons(c); }
  go('course');
  document.querySelectorAll('.nav').forEach(n => n.classList.toggle('on', n.dataset.go === 'catalog'));
}

async function renderMy() {
  state.subs = await api('get_subscriptions');
  const courses = (await api('get_courses')).filter(c => state.subs[c.id]);
  $('#myGrid').innerHTML = courses.length ? '' : '<div class="empty">Вы пока не купили ни одного курса. Загляните в каталог.</div>';
  courses.forEach(c => {
    const s = state.subs[c.id];
    $('#myGrid').append(card(c, () => s === 'active' ? openLessons(c) : openCourse(c), `<div class="price"><span class="badge ${s}">${statusText[s]}</span></div>`));
  });
}

async function openLessons(c) {
  state.course = c;
  $('#lTitle').textContent = c.title;
  $('#lTeacher').textContent = 'Преподаватель: ' + c.teacher;
  const lessons = await api('get_lessons', c.id);
  $('#lessonList').innerHTML = '';
  lessons.forEach(l => {
    const li = document.createElement('li');
    li.innerHTML = `<button data-id="${l.id}"><i>${l.position}</i>${l.title}</button>`;
    li.firstChild.onclick = () => showLesson(l);
    $('#lessonList').append(li);
  });
  go('lessons');
  document.querySelectorAll('.nav').forEach(n => n.classList.toggle('on', n.dataset.go === 'my'));
  if (lessons.length) showLesson(lessons[0]);
}

async function showLesson(l) {
  state.lesson = l;
  document.querySelectorAll('#lessonList button').forEach(b => b.classList.toggle('on', +b.dataset.id === l.id));
  $('#video').src = embed(l.video_url);
  $('#lessonTitle').textContent = l.title;
  const h = await api('get_homework', l.id);
  if (!h) { $('#hwBox').innerHTML = '<p class="sub">К этому уроку нет домашнего задания.</p>'; return; }
  let html = `<div class="hw"><b>Домашнее задание</b><p>${h.description}</p>`;
  if (h.grade) html += `<p>Оценка: <span class="grade">${h.grade}</span> из 10</p>`;
  else if (h.file_url) html += '<p><span class="badge pending">Работа отправлена, ждёт проверки</span></p>';
  if (!h.grade) html += `<div class="field"><input id="fileUrl" placeholder="Ссылка на файл в Google Drive" value="${h.file_url || ''}"><button class="btn" id="sendHw">${h.file_url ? 'Отправить заново' : 'Отправить работу'}</button></div>`;
  $('#hwBox').innerHTML = html + '</div>';
  const send = $('#sendHw');
  if (send) send.onclick = async () => {
    const u = $('#fileUrl').value.trim();
    if (!u.startsWith('https://')) return toast('Ссылка должна начинаться с https://');
    await api('submit_homework', l.id, u); toast('Работа отправлена'); showLesson(l);
  };
}

async function renderGrades() {
  const rows = await api('get_grades') || [
    {course: 'Python с нуля', lesson: 'Переменные и типы данных', grade: 9},
    {course: 'Python с нуля', lesson: 'Установка и первая программа', grade: null}];
  $('#gradesBox').innerHTML = rows.length
    ? `<table><tr><th>Курс</th><th>Урок</th><th>Оценка</th></tr>${rows.map(r => `<tr><td>${r.course}</td><td>${r.lesson}</td><td>${r.grade ?? '<span class="badge pending">На проверке</span>'}</td></tr>`).join('')}</table>`
    : '<div class="empty">Сданных работ пока нет.</div>';
}

document.querySelectorAll('[data-go]').forEach(b => b.onclick = () => go(b.dataset.go));
$('#logout').onclick = () => api('logout');
go('catalog');
