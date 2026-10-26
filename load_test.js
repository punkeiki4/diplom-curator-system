import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend } from 'k6/metrics';

// ── Метрики ────────────────────────────────────────────────────────────────
const errorRate   = new Rate('error_rate');
const loginTrend  = new Trend('login_duration');
const apiTrend    = new Trend('api_duration');

// ── Конфигурация нагрузки ──────────────────────────────────────────────────
export const options = {
  stages: [
    { duration: '10s', target: 5  },  // разгон: 5 пользователей
    { duration: '20s', target: 20 },  // основная нагрузка: 20 пользователей
    { duration: '10s', target: 50 },  // пик: 50 пользователей
    { duration: '10s', target: 0  },  // остывание
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'],  // 95% запросов < 500ms
    error_rate:        ['rate<0.05'],  // ошибок < 5%
  },
};

const BASE = 'http://localhost:5062';

// ── Пул тестовых пользователей ─────────────────────────────────────────────
const USERS = [
  { email: 'curator1@diplom.ru',  password: 'Curator1!'  },
  { email: 'curator2@diplom.ru',  password: 'Curator2!'  },
  { email: 'curator3@diplom.ru',  password: 'Curator3!'  },
  { email: 'student1@diplom.ru',  password: 'Student1!'  },
  { email: 'student2@diplom.ru',  password: 'Student2!'  },
  { email: 'vicedean1@diplom.ru', password: 'ViceDean1!' },
];

// ── Основной сценарий ──────────────────────────────────────────────────────
export default function () {
  const user = USERS[Math.floor(Math.random() * USERS.length)];

  // 1. Авторизация
  const loginStart = Date.now();
  const loginRes = http.post(
    `${BASE}/api/auth/login`,
    JSON.stringify({ email: user.email, password: user.password }),
    { headers: { 'Content-Type': 'application/json' } }
  );
  loginTrend.add(Date.now() - loginStart);

  const loginOk = check(loginRes, {
    'login status 200': (r) => r.status === 200,
    'token present':    (r) => r.json('token') !== null,
  });
  errorRate.add(!loginOk);

  if (!loginOk) return;

  const token   = loginRes.json('token');
  const headers = {
    'Content-Type':  'application/json',
    'Authorization': `Bearer ${token}`,
  };

  sleep(0.2);

  // 2. Список студентов группы (только кураторы имеют данные)
  const apiStart = Date.now();
  const studRes = http.get(`${BASE}/api/students/my-group`, { headers });
  apiTrend.add(Date.now() - apiStart);
  check(studRes, { 'students 200': (r) => r.status === 200 });

  sleep(0.1);

  // 3. Уведомления
  const notifRes = http.get(`${BASE}/api/notifications/my`, { headers });
  check(notifRes, { 'notifications 200': (r) => r.status === 200 });

  sleep(0.1);

  // 4. Расписание
  const schedRes = http.get(`${BASE}/api/schedules/my`, { headers });
  check(schedRes, { 'schedule 200': (r) => r.status === 200 });

  sleep(0.3);
}
