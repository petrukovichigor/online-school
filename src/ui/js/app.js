// The interface only displays data and calls Python (pywebview.api.<name>).
// Without pywebview it runs on the demo data D, so the pages can be opened by double-click.
const $ = (s, r = document) => r.querySelector(s), $$ = (s, r = document) => [...r.querySelectorAll(s)];
const esc = s => String(s ?? '').replace(/[&<>"']/g, c => ({'&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'}[c]));
const ST = {pending: 'Awaiting payment', active: 'Active', cancelled: 'Cancelled', paid: 'Paid', refunded: 'Refunded'};
const badge = s => `<span class="badge ${s}">${ST[s] || s}</span>`;
const YT = 'https://www.youtube.com/watch?v=rfscVS0vtbw';
const page = document.body.dataset.page;

/* ---------- demo data ---------- */
let seq = 100;
const D = {
  cats: ['Programming', 'Languages', 'Design', 'Marketing', 'Business'],
  courses: [
    {id: 1, title: 'Python from Scratch', category: 'Programming', teacher: 'Anna Kovalyova', price: 120, description: 'Language basics, functions, files and databases.', mine: true},
    {id: 2, title: 'English for IT', category: 'Languages', teacher: 'Ivan Sidorov', price: 90, description: 'Vocabulary and speaking practice for IT professionals.'},
    {id: 3, title: 'UX/UI Basics', category: 'Design', teacher: 'Maria Lis', price: 110, description: 'From user research to a prototype in Figma.'},
    {id: 4, title: 'SQL for Analysts', category: 'Programming', teacher: 'Anna Kovalyova', price: 140, description: 'Queries, joins, aggregates and window functions.', mine: true},
    {id: 5, title: 'Digital Marketing', category: 'Marketing', teacher: 'Oleg Mart', price: 100, description: 'Advertising, analytics and sales funnels.'},
    {id: 6, title: 'Finance Basics', category: 'Business', teacher: 'Irina Finkel', price: 80, description: 'Personal budget, investing and financial planning.'}],
  subs: {1: {status: 'active', tx: 'TXN-1525916985'}, 2: {status: 'pending'}, 4: {status: 'cancelled', tx: 'TXN-3805748088'}},
  lessons: {
    1: [{id: 1, position: 1, title: 'Installation and your first program', video_url: YT, hws: [{id: 1, description: 'Print your name and age.'}]},
        {id: 2, position: 2, title: 'Variables and data types', video_url: YT, hws: [{id: 2, description: 'Solve three data type exercises.'}]}],
    4: [{id: 3, position: 1, title: 'SELECT and filtering', video_url: YT, hws: []}]},
  my: {1: {file_url: null, grade: null}, 2: {file_url: 'https://drive.google.com/demo', grade: 9}},
  students: {1: [{name: 'Yegor Melnik', email: 'egor@mail.by', status: 'active'}, {name: 'Alina Rudaya', email: 'alina@mail.by', status: 'pending'}, {name: 'Pavel Shilo', email: 'pavel@mail.by', status: 'cancelled'}],
             4: [{name: 'Darya Kim', email: 'dasha@mail.by', status: 'active'}]},
  subm: [{id: 1, course: 1, student: 'Yegor Melnik', lesson: 'Installation and your first program', file_url: 'https://drive.google.com/demo1', grade: null},
         {id: 2, course: 1, student: 'Darya Kim', lesson: 'Variables and data types', file_url: 'https://drive.google.com/demo2', grade: 8}]
};
const cid = id => D.courses.find(c => c.id === id);
const C = {
  me: () => ({name: page === 'teacher' ? 'Anna Kovalyova' : 'Igor Petrukovich', email: page === 'teacher' ? 'anna@school.by' : 'igor@mail.by'}),
  login: (r, e, p) => ({ok: true, role: r}),
  register: (r, d) => ({ok: true, role: r}),
  logout: () => true,
  get_categories: () => D.cats,
  get_courses: () => D.courses,
  get_subscriptions: () => Object.fromEntries(Object.entries(D.subs).map(([k, v]) => [k, v.status])),
  get_payments: () => Object.entries(D.subs).map(([k, v]) => ({course: cid(+k).title, amount: cid(+k).price, status: {pending: 'pending', active: 'paid', cancelled: v.tx ? 'refunded' : 'pending'}[v.status], tx: v.tx || ''})),
  buy_course: id => (D.subs[id] = {status: 'pending'}, true),
  pay_course: id => (D.subs[id] = {status: 'active', tx: 'TXN-' + Math.floor(1e9 + Math.random() * 9e9)}, true),
  cancel_course: id => (delete D.subs[id], true),
  refund_course: id => (D.subs[id].status = 'cancelled', true),
  get_lessons: id => (D.lessons[id] || []).map(l => ({...l, video_url: D.subs[id]?.status === 'active' ? l.video_url : ''})),
  get_homework: lid => { const l = Object.values(D.lessons).flat().find(x => x.id === lid), h = l?.hws[0]; return h ? {homework_id: h.id, description: h.description, ...(D.my[lid] || {file_url: null, grade: null})} : null; },
  submit_homework: (lid, url) => (D.my[lid] = {file_url: url, grade: null}, true),
  get_grades: () => Object.entries(D.my).map(([lid, m]) => ({course: 'Python from Scratch', lesson: Object.values(D.lessons).flat().find(x => x.id === +lid).title, grade: m.file_url ? m.grade : null})),
  t_courses: () => D.courses.filter(c => c.mine).map(c => { const n = (D.students[c.id] || []).filter(s => s.status === 'active').length; return {...c, students: n, revenue: n * c.price}; }),
  t_create_course: d => (D.courses.push({id: ++seq, teacher: 'Anna Kovalyova', mine: true, ...d}), true),
  t_students: id => D.students[id] || [],
  t_lessons: id => D.lessons[id] || [],
  t_add_lesson: (id, d) => ((D.lessons[id] = D.lessons[id] || []).push({id: ++seq, hws: [], ...d}), true),
  t_delete_lesson: (id, lid) => (D.lessons[id] = D.lessons[id].filter(l => l.id !== lid), true),
  t_add_homework: (lid, text) => (Object.values(D.lessons).flat().find(l => l.id === lid).hws.push({id: ++seq, description: text}), true),
  t_submissions: id => D.subm.filter(s => s.course === id),
  t_grade: (sid, g) => (D.subm.find(s => s.id === sid).grade = g, true)
};
const api = async (n, ...a) => {
  const f = window.pywebview && pywebview.api && pywebview.api[n];
  if (f) return f(...a);
  if (window.pywebview) console.warn('Python has no method', n);
  return C[n] ? C[n](...a) : null;
};

/* ---------- common ---------- */
function toast(t) { const el = $('#toast'); el.textContent = t; el.classList.add('on'); setTimeout(() => el.classList.remove('on'), 2400); }
function ask(title, body, ok, cb, danger) {
  const d = $('#dlg');
  d.innerHTML = `<form method="dialog"><h2 style="margin-top:0">${title}</h2><div class="dbody">${body}</div><div class="err" id="derr"></div><div class="dact"><button type="button" class="btn ghost" id="dno">Back</button><button class="btn ${danger ? 'danger' : ''}" id="dyes">${ok}</button></div></form>`;
  $('#dno').onclick = () => d.close();
  $('#dyes').onclick = async e => { e.preventDefault(); const r = await cb(d); if (r === true || r === undefined) d.close(); else $('#derr').textContent = r; };
  d.showModal();
}
function go(id, nav) {
  $$('.screen').forEach(s => s.classList.toggle('on', s.id === id));
  $$('.nav').forEach(n => n.classList.toggle('on', n.dataset.go === (nav || id)));
  (window.onGo || (() => {}))(id);
}
function tabs(el, items, cur, cb) {
  el.innerHTML = items.map(([k, t]) => `<button class="tab ${k === cur ? 'on' : ''}" data-k="${k}">${t}</button>`).join('');
  $$('.tab', el).forEach(b => b.onclick = () => cb(b.dataset.k));
}
const stats = (el, arr) => el.innerHTML = arr.map(([v, t]) => `<div class="stat"><b>${v}</b><span>${t}</span></div>`).join('');
const embed = u => { const m = (u || '').match(/(?:v=|youtu\.be\/)([\w-]{11})/); return m ? 'https://www.youtube.com/embed/' + m[1] : ''; };
const reYT = /^https:\/\/(www\.)?(youtube\.com|youtu\.be)\//;

if (page !== 'auth') {
  $$('[data-go]').forEach(b => b.onclick = () => go(b.dataset.go));
  $('#logout').onclick = async () => { await api('logout'); location.href = 'auth.html'; };
  window.loadMe = async () => {
    const m = await api('me');
    if (m) { $('#userName').textContent = m.name; $('#userEmail').textContent = m.email; }
    else if (window.pywebview) location.href = 'auth.html'; // not signed in
  };
}

/* ---------- sign in and sign up ---------- */
if (page === 'auth') {
  let role = 'student', mode = 'login';
  const reEmail = /^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$/, rePhone = /^\+375(25|29|33|44)\d{7}$/;
  const draw = () => {
    const reg = mode === 'register';
    $('#regOnly').hidden = !reg;
    $('#mode').hidden = role === 'teacher';
    $('#note').hidden = role !== 'teacher';
    $('#ttl').textContent = reg ? 'Sign up' : 'Sign in';
    $('#go').textContent = reg ? 'Create account' : 'Sign in';
    $('#err').textContent = '';
  };
  const seg = (id, set) => $$(`#${id} button`).forEach(b => b.onclick = () => { $$(`#${id} button`).forEach(x => x.classList.toggle('on', x === b)); set(b.dataset.v); draw(); });
  seg('role', v => { role = v; if (v === 'teacher') mode = 'login'; });
  seg('mode', v => mode = v);
  $('#form').onsubmit = async e => {
    e.preventDefault();
    const em = $('#em').value.trim().toLowerCase(), pw = $('#pw').value, err = t => $('#err').textContent = t;
    if (!reEmail.test(em)) return err('Enter a valid email');
    if (mode === 'login') {
      if (!pw) return err('Enter your password');
      const r = await api('login', role, em, pw);
      if (!r || !r.ok) return err((r && r.error) || 'Wrong email or password');
      return location.href = r.role === 'teacher' ? 'teacher.html' : 'student.html';
    }
    const d = {first_name: $('#fn').value.trim(), last_name: $('#ln').value.trim(), phone: $('#ph').value.trim(), email: em, password: pw};
    if (!d.first_name || !d.last_name) return err('Enter your first and last name');
    if (d.phone && !rePhone.test(d.phone)) return err('Phone format: +375291234567');
    if (pw.length < 8) return err('Password must be at least 8 characters');
    const r = await api('register', role, d);
    if (!r || !r.ok) return err((r && r.error) || 'Could not sign up');
    location.href = 'student.html';
  };
}

/* ---------- student ---------- */
if (page === 'student') {
  const cache = {courses: [], subs: {}}, F = {q: '', cat: null, sort: 'title', min: '', max: '', hide: false}, st = {tab: 'all', course: null};
  const SORT = {title: (a, b) => a.title.localeCompare(b.title, 'en'), price_asc: (a, b) => a.price - b.price, price_desc: (a, b) => b.price - a.price, teacher: (a, b) => a.teacher.localeCompare(b.teacher, 'en')};
  const load = async () => {
    const [c, s] = await Promise.all([cache.courses.length ? cache.courses : api('get_courses'), api('get_subscriptions')]); // courses are fetched once
    cache.courses = c || []; cache.subs = s || {};
  };
  const card = (c, extra = '') => {
    const d = document.createElement('div');
    d.className = 'course'; d.tabIndex = 0;
    d.innerHTML = `<div class="cover">${esc(c.category)}</div><div class="cbody"><strong>${esc(c.title)}</strong><small>${esc(c.teacher)}</small>${extra}</div>`;
    paintCover(d, c.category);
    return d;
  };
  window.onGo = async id => {
    if (id === 'catalog') { await load(); drawCatalog(); }
    if (id === 'my') { await load(); drawMy(); }
    if (id === 'payments') drawPay();
    if (id === 'grades') drawGrades();
  };

  function drawCatalog() {
    const q = F.q.toLowerCase(), s = cache.subs;
    $('#chips').innerHTML = '';
    ['All', ...new Set(cache.courses.map(c => c.category))].forEach(n => {
      const k = n === 'All' ? cache.courses.length : cache.courses.filter(c => c.category === n).length, b = document.createElement('button');
      b.className = 'chip' + ((F.cat || 'All') === n ? ' on' : ''); b.textContent = `${n} · ${k}`;
      b.onclick = () => { F.cat = n === 'All' ? null : n; drawCatalog(); };
      $('#chips').append(b);
    });
    const list = cache.courses.filter(c => (!F.cat || c.category === F.cat) && (!q || (c.title + c.teacher + c.description).toLowerCase().includes(q))
      && (F.min === '' || c.price >= +F.min) && (F.max === '' || c.price <= +F.max) && (!F.hide || !s[c.id] || s[c.id] === 'cancelled')).sort(SORT[F.sort]);
    $('#count').textContent = `Courses found: ${list.length} of ${cache.courses.length}`;
    $('#courseGrid').innerHTML = list.length ? '' : `<div class="empty">${cache.courses.length ? 'Nothing found. Try changing the filters.' : 'No courses were loaded. Sign in again and check the Python console for errors.'}</div>`;
    list.forEach(c => { const d = card(c, `<div class="price">${c.price} BYN ${s[c.id] ? badge(s[c.id]) : ''}</div>`); d.onclick = () => openCourse(c); $('#courseGrid').append(d); });
  }
  [['q', 'q'], ['sort', 'sort'], ['pmin', 'min'], ['pmax', 'max']].forEach(([id, k]) => $('#' + id).oninput = e => { F[k] = e.target.value; drawCatalog(); });
  $('#hide').onchange = e => { F.hide = e.target.checked; drawCatalog(); };
  $('#reset').onclick = () => { Object.assign(F, {q: '', cat: null, sort: 'title', min: '', max: '', hide: false}); $$('.toolbar input').forEach(i => i.type === 'checkbox' ? i.checked = false : i.value = ''); $('#sort').value = 'title'; drawCatalog(); };

  const doCancel = c => ask('Cancel the order?', `The order for the course “${esc(c.title)}” will be deleted. You have not been charged.`, 'Cancel order', async () => { await api('cancel_course', c.id); toast('Order cancelled'); await load(); st.back ? drawMy() : openCourse(c); }, true);
  const doRefund = c => ask('Refund this course?', `You will get back ${c.price} BYN for the course “${esc(c.title)}”. Access to the lessons will be closed.`, 'Refund', async () => { await api('refund_course', c.id); toast('Refund completed'); await load(); st.back ? drawMy() : openCourse(c); }, true);

  async function openCourse(c, back) {
    st.course = c; st.back = back; await load();
    $('#cTitle').textContent = c.title; $('#cMeta').textContent = `${c.category}, teacher ${c.teacher}`;
    $('#cDesc').textContent = c.description; $('#cPrice').textContent = c.price + ' BYN';
    const ls = (await api('get_lessons', c.id)) || [];
    $('#cLessons').innerHTML = ls.length ? ls.map(l => `<li><button disabled><i>${l.position}</i>${esc(l.title)}</button></li>`).join('') : '<li class="sub">No lessons have been added yet.</li>';
    const s = cache.subs[c.id], b = $('#cBuy'), sec = $('#cSec');
    sec.hidden = true; b.className = 'btn';
    if (!s || s === 'cancelled') { $('#cState').textContent = 'Payment first, then access to the lessons.'; b.textContent = 'Buy'; b.onclick = async () => { await api('buy_course', c.id); toast('Order created, payment pending'); openCourse(c); }; }
    else if (s === 'pending') {
      $('#cState').innerHTML = badge('pending'); b.textContent = 'Pay'; b.className = 'btn alt';
      b.onclick = async () => { await api('pay_course', c.id); toast('Payment successful'); openCourse(c); };
      sec.hidden = false; sec.textContent = 'Cancel order'; sec.onclick = () => doCancel(c);
    } else {
      $('#cState').innerHTML = badge('paid') + ' Course paid'; b.textContent = 'Go to lessons'; b.onclick = () => openLessons(c);
      sec.hidden = false; sec.textContent = 'Refund'; sec.onclick = () => doRefund(c);
    }
    go('course', 'catalog');
  }

  function drawMy() {
    const mine = cache.courses.filter(c => cache.subs[c.id]), n = k => mine.filter(c => cache.subs[c.id] === k).length;
    tabs($('#myTabs'), [['all', `All · ${mine.length}`], ['active', `Active · ${n('active')}`], ['pending', `Awaiting payment · ${n('pending')}`], ['cancelled', `Cancelled · ${n('cancelled')}`]], st.tab, k => { st.tab = k; drawMy(); });
    const list = mine.filter(c => st.tab === 'all' || cache.subs[c.id] === st.tab);
    $('#myGrid').innerHTML = list.length ? '' : '<div class="empty">Nothing here yet. Browse the catalog.</div>';
    list.forEach(c => {
      const s = cache.subs[c.id], d = card(c, `<div class="price">${badge(s)}</div><div class="acts"></div>`), a = $('.acts', d);
      const add = (t, cls, f) => { const b = document.createElement('button'); b.className = 'btn sm ' + cls; b.textContent = t; b.onclick = e => { e.stopPropagation(); st.back = true; f(); }; a.append(b); };
      if (s === 'active') { add('Lessons', '', () => openLessons(c)); add('Refund', 'ghost danger', () => doRefund(c)); }
      if (s === 'pending') { add('Pay', 'alt', async () => { await api('pay_course', c.id); toast('Payment successful'); await load(); drawMy(); }); add('Cancel order', 'ghost danger', () => doCancel(c)); }
      if (s === 'cancelled') add('Buy again', '', () => openCourse(c));
      d.onclick = () => s === 'active' ? openLessons(c) : openCourse(c, true);
      $('#myGrid').append(d);
    });
  }

  async function openLessons(c) {
    $('#lTitle').textContent = c.title; $('#lTeacher').textContent = 'Teacher: ' + c.teacher;
    const ls = (await api('get_lessons', c.id)) || []; $('#lessonList').innerHTML = '';
    ls.forEach(l => { const li = document.createElement('li'); li.innerHTML = `<button data-id="${l.id}"><i>${l.position}</i>${esc(l.title)}</button>`; li.firstChild.onclick = () => showLesson(l); $('#lessonList').append(li); });
    go('lessons', 'my');
    if (ls.length) showLesson(ls[0]); else { $('#video').removeAttribute('src'); $('#lessonTitle').textContent = 'No lessons have been added yet'; $('#hwBox').innerHTML = ''; }
  }
  async function showLesson(l) {
    $$('#lessonList button').forEach(b => b.classList.toggle('on', +b.dataset.id === l.id));
    $('#video').src = embed(l.video_url); $('#lessonTitle').textContent = l.title;
    const h = await api('get_homework', l.id);
    if (!h) { $('#hwBox').innerHTML = '<p class="sub">This lesson has no homework.</p>'; return; }
    let html = `<div class="hw"><b>Homework</b><p>${esc(h.description)}</p>`;
    if (h.grade) html += `<p>Grade: <span class="grade">${h.grade}</span> out of 10</p>`;
    else {
      if (h.file_url) html += `<p>${badge('pending').replace('Awaiting payment', 'Submitted, awaiting review')}</p>`;
      html += `<div class="field"><input id="fileUrl" placeholder="Link to a file on Google Drive" value="${esc(h.file_url || '')}"><button class="btn" id="sendHw">${h.file_url ? 'Resubmit' : 'Submit work'}</button></div>`;
    }
    $('#hwBox').innerHTML = html + '</div>';
    if ($('#sendHw')) $('#sendHw').onclick = async () => {
      const u = $('#fileUrl').value.trim();
      if (!u.startsWith('https://')) return toast('The link must start with https://');
      await api('submit_homework', l.id, u); toast('Work submitted'); showLesson(l);
    };
  }

  async function drawPay() {
    const rows = await api('get_payments') || [], f = $('#payF').value, paid = rows.filter(r => r.status === 'paid'), back = rows.filter(r => r.status === 'refunded');
    stats($('#payStats'), [[paid.reduce((s, r) => s + r.amount, 0) + ' BYN', 'Paid in total'], [back.reduce((s, r) => s + r.amount, 0) + ' BYN', 'Refunded'], [rows.filter(r => r.status === 'pending').length, 'Awaiting payment']]);
    const list = rows.filter(r => !f || r.status === f);
    $('#payBox').innerHTML = list.length ? `<table><tr><th>Course</th><th>Amount</th><th>Status</th><th>Transaction</th></tr>${list.map(r => `<tr><td>${esc(r.course)}</td><td>${r.amount} BYN</td><td>${badge(r.status)}</td><td><small>${esc(r.tx) || '—'}</small></td></tr>`).join('')}</table>` : '<div class="empty">No payments.</div>';
  }
  $('#payF').onchange = drawPay;

  async function drawGrades() {
    const rows = await api('get_grades') || [], f = $('#gF').value, done = rows.filter(r => r.grade != null);
    stats($('#gStats'), [[done.length ? (done.reduce((s, r) => s + r.grade, 0) / done.length).toFixed(1) : '—', 'Average grade'], [done.length, 'Reviewed'], [rows.length - done.length, 'Under review']]);
    const list = rows.filter(r => !f || (f === 'done') === (r.grade != null));
    $('#gradesBox').innerHTML = list.length ? `<table><tr><th>Course</th><th>Lesson</th><th>Grade</th></tr>${list.map(r => `<tr><td>${esc(r.course)}</td><td>${esc(r.lesson)}</td><td>${r.grade ?? '<span class="badge pending">Under review</span>'}</td></tr>`).join('')}</table>` : '<div class="empty">No submissions yet.</div>';
  }
  $('#gF').onchange = drawGrades;

  const start = (() => { let ok = false; return () => { if (!ok) { ok = true; loadMe(); go('catalog'); } }; })();
  window.addEventListener('pywebviewready', start);
  setTimeout(() => { if (!window.pywebview) start(); }, 400);
}

/* ---------- teacher ---------- */
if (page === 'teacher') {
  const st = {course: null, tab: 'students', sf: '', ss: '', cf: ''};
  window.onGo = id => { if (id === 'tcourses') drawCourses(); };

  async function drawCourses() {
    const cs = await api('t_courses') || [];
    stats($('#tStats'), [[cs.length, 'Courses'], [cs.reduce((s, c) => s + c.students, 0), 'Active students'], [cs.reduce((s, c) => s + c.revenue, 0) + ' BYN', 'Revenue from active subscriptions']]);
    $('#tGrid').innerHTML = cs.length ? '' : '<div class="empty">You have no courses yet. Click “New course”.</div>';
    cs.forEach(c => {
      const d = document.createElement('div'); d.className = 'course'; d.tabIndex = 0;
      d.innerHTML = `<div class="cover">${esc(c.category)}</div><div class="cbody"><strong>${esc(c.title)}</strong><small>Active students: ${c.students}</small><div class="price">${c.price} BYN</div></div>`;
      paintCover(d, c.category); d.onclick = () => openCourse(c); $('#tGrid').append(d);
    });
  }
  $('#newCourse').onclick = async () => {
    const cats = await api('get_categories') || [];
    ask('New course', `<label class="fld">Title<input id="nT"></label><label class="fld">Category<select id="nC">${cats.map(c => `<option>${esc(c)}</option>`).join('')}</select></label><label class="fld">Price, BYN<input id="nP" type="number" min="1" step="0.01"></label><label class="fld">Description<textarea id="nD" rows="3"></textarea></label>`, 'Create', async () => {
      const d = {title: $('#nT').value.trim(), category: $('#nC').value, price: +$('#nP').value, description: $('#nD').value.trim()};
      if (!d.title) return 'Enter a course title';
      if (!(d.price > 0)) return 'Price must be greater than zero';
      const r = await api('t_create_course', d); if (r === false) return 'A course with this title already exists';
      toast('Course created'); drawCourses();
    });
  };

  function openCourse(c) {
    st.course = c; st.tab = 'students';
    $('#tcTitle').textContent = c.title; $('#tcMeta').textContent = `${c.category}, ${c.price} BYN`;
    go('tcourse', 'tcourses'); drawTab();
  }
  function drawTab() {
    tabs($('#tTabs'), [['students', 'Students'], ['lessons', 'Lessons and assignments'], ['checks', 'Review work']], st.tab, k => { st.tab = k; drawTab(); });
    ({students: drawStudents, lessons: drawLessons, checks: drawChecks})[st.tab]();
  }
  async function drawStudents() {
    const all = await api('t_students', st.course.id) || [], q = st.sq || '';
    $('#tBody').innerHTML = `<div class="toolbar"><input class="grow" id="sq" type="search" placeholder="Search by name or email" value="${esc(q)}"><select id="ss"><option value="">All statuses</option><option value="active">Active</option><option value="pending">Awaiting payment</option><option value="cancelled">Cancelled</option></select></div><div id="sTab"></div>`;
    $('#ss').value = st.ss;
    const draw = () => {
      const l = all.filter(s => (!st.ss || s.status === st.ss) && (s.name + s.email).toLowerCase().includes((st.sq || '').toLowerCase()));
      $('#sTab').innerHTML = l.length ? `<table><tr><th>Student</th><th>Email</th><th>Subscription</th></tr>${l.map(s => `<tr><td>${esc(s.name)}</td><td>${esc(s.email)}</td><td>${badge(s.status)}</td></tr>`).join('')}</table>` : '<div class="empty">No students found.</div>';
    };
    $('#sq').oninput = e => { st.sq = e.target.value; draw(); }; $('#ss').onchange = e => { st.ss = e.target.value; draw(); }; draw();
  }
  async function drawLessons() {
    const ls = await api('t_lessons', st.course.id) || [];
    $('#tBody').innerHTML = `<div class="toolbar"><div class="grow"></div><button class="btn" id="addL">+ Add lesson</button></div><div class="panel" id="lBox"></div>`;
    $('#lBox').innerHTML = ls.length ? ls.sort((a, b) => a.position - b.position).map(l => `<div class="lrow"><i style="width:24px;font-style:normal;color:var(--mute)">${l.position}</i><div class="grow"><b>${esc(l.title)}</b><small>${l.hws.length ? 'Assignments: ' + l.hws.length + '. ' + esc(l.hws.map(h => h.description).join(' | ')) : 'No assignments'}</small></div><button class="btn sm ghost" data-hw="${l.id}">+ Assignment</button><button class="btn sm ghost danger" data-del="${l.id}">Delete</button></div>`).join('') : '<div class="empty">No lessons yet.</div>';
    $$('[data-hw]').forEach(b => b.onclick = () => ask('New assignment', '<label class="fld">Description<textarea id="hD" rows="3"></textarea></label>', 'Add', async () => { const t = $('#hD').value.trim(); if (!t) return 'Describe the assignment'; await api('t_add_homework', +b.dataset.hw, t); toast('Assignment added'); drawLessons(); }));
    $$('[data-del]').forEach(b => b.onclick = () => ask('Delete lesson?', 'The lesson’s assignments and submitted work will be deleted with it.', 'Delete', async () => { await api('t_delete_lesson', st.course.id, +b.dataset.del); toast('Lesson deleted'); drawLessons(); }, true));
    $('#addL').onclick = () => ask('New lesson', `<label class="fld">Title<input id="lT"></label><div class="two"><label class="fld">Order<input id="lP" type="number" min="1" value="${ls.length + 1}"></label></div><label class="fld">YouTube link<input id="lU" placeholder="https://www.youtube.com/watch?v=..."></label>`, 'Add', async () => {
      const d = {title: $('#lT').value.trim(), position: +$('#lP').value, video_url: $('#lU').value.trim(), hws: []};
      if (!d.title) return 'Enter a lesson title';
      if (!(d.position > 0)) return 'Order must be greater than zero';
      if (ls.some(l => l.position === d.position)) return 'A lesson with this order already exists';
      if (!reYT.test(d.video_url)) return 'A YouTube link (https://...) is required';
      await api('t_add_lesson', st.course.id, d); toast('Lesson added'); drawLessons();
    });
  }
  async function drawChecks() {
    const all = await api('t_submissions', st.course.id) || [];
    $('#tBody').innerHTML = `<div class="toolbar"><select id="cf"><option value="">All submissions</option><option value="wait">Not reviewed</option><option value="done">Reviewed</option></select></div><div id="cTab"></div>`;
    $('#cf').value = st.cf;
    const draw = () => {
      const l = all.filter(s => !st.cf || (st.cf === 'done') === (s.grade != null));
      $('#cTab').innerHTML = l.length ? `<table><tr><th>Student</th><th>Lesson</th><th>File</th><th>Grade</th></tr>${l.map(s => `<tr><td>${esc(s.student)}</td><td>${esc(s.lesson)}</td><td><a href="${esc(s.file_url)}" target="_blank" rel="noopener">Open</a></td><td><select data-g="${s.id}"><option value="">—</option>${[1, 2, 3, 4, 5, 6, 7, 8, 9, 10].map(n => `<option ${s.grade === n ? 'selected' : ''}>${n}</option>`).join('')}</select></td></tr>`).join('')}</table>` : '<div class="empty">No submissions.</div>';
      $$('[data-g]').forEach(s => s.onchange = async () => { if (!s.value) return; await api('t_grade', +s.dataset.g, +s.value); const r = all.find(x => x.id === +s.dataset.g); r.grade = +s.value; toast('Grade saved'); });
    };
    $('#cf').onchange = e => { st.cf = e.target.value; draw(); }; draw();
  }

  const start = (() => { let ok = false; return () => { if (!ok) { ok = true; loadMe(); go('tcourses'); } }; })();
  window.addEventListener('pywebviewready', start);
  setTimeout(() => { if (!window.pywebview) start(); }, 400);
}
