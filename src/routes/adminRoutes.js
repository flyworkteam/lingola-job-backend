const express = require("express");
const pool = require("../config/db");

const router = express.Router();

function layout(title, content, activeNav = "") {
  const navItems = [
    { path: "/admin", label: "Dashboard", icon: "M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" },
    { path: "/admin/languages", label: "Languages", icon: "M3.055 11H5a2 2 0 012 2v1a2 2 0 002 2 2 2 0 012 2v2.945M8 3.935V5.5A2.5 2.5 0 0010.5 8h.5a2 2 0 012 2 2 2 0 104 0h.5a2.5 2.5 0 002.5-2.5V8m0 4.5a2.5 2.5 0 01-2.5 2.5h-.5a2 2 0 00-2 2v.055M12 20.055V18a2 2 0 00-2-2h-2a2 2 0 00-2 2v2.055M16 3.055V4.5A2.5 2.5 0 0113.5 7h-.5a2 2 0 00-2 2v2.945" },
    { path: "/admin/tracks", label: "Tracks", icon: "M3 21v-4m0 0V5a2 2 0 012-2h6.5L17 8.5M3 17l4-4m0 0l4 4m-4-4v4" },
    { path: "/admin/words", label: "Words", icon: "M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" },
    { path: "/admin/users", label: "Users", icon: "M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" },
  ];
  const sidebarNav = navItems.map((item) => {
    const isActive = activeNav === item.path;
    return `<a href="${item.path}" class="side-link ${isActive ? "active" : ""}"><span class="side-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="${item.icon}"/></svg></span><span>${item.label}</span></a>`;
  }).join("");

  return `<!DOCTYPE html>
<html lang="tr">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>${title} · Lingola Admin</title>
  <link rel="preconnect" href="https://fonts.googleapis.com" />
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
  <link href="https://fonts.googleapis.com/css2?family=DM+Sans:ital,opsz,wght@0,9..40,400;0,9..40,500;0,9..40,600;0,9..40,700&display=swap" rel="stylesheet" />
  <style>
    :root {
      --bg: #F9F9F9;
      --surface: #ffffff;
      --surface-hover: #f1f5f9;
      --border: #e2e8f0;
      --text: #1e293b;
      --text-muted: #64748b;
      --accent: #0575E6;
      --accent-hover: #0461c4;
      --navy: #0f172a;
      --navy-light: #1e293b;
      --input-bg: #ffffff;
      --radius: 12px;
      --radius-sm: 8px;
      --shadow: 0 2px 12px rgba(0,0,0,.06);
      --card-blue: #0575E6;
      --card-purple: #7c3aed;
      --card-green: #059669;
      --card-orange: #ea580c;
    }
    * { box-sizing: border-box; }
    body { font-family: 'DM Sans', system-ui, sans-serif; margin: 0; background: var(--bg); color: var(--text); line-height: 1.5; min-height: 100vh; display: flex; flex-direction: column; }
    .app-wrap { display: flex; min-height: 100vh; }
    .topbar { height: 56px; background: var(--navy); color: #fff; display: flex; align-items: center; justify-content: space-between; padding: 0 24px; flex-shrink: 0; }
    .topbar-logo { font-size: 1.25rem; font-weight: 700; letter-spacing: -0.02em; display: flex; align-items: center; gap: 10px; }
    .topbar-logo span { color: var(--accent); }
    .topbar-user { font-size: 0.875rem; color: rgba(255,255,255,.8); }
    .sidebar { width: 240px; background: var(--navy); color: #fff; padding: 16px 0; flex-shrink: 0; }
    .side-link { display: flex; align-items: center; gap: 12px; padding: 12px 20px; color: rgba(255,255,255,.75); text-decoration: none; font-size: 0.9375rem; font-weight: 500; transition: background .15s, color .15s; border-left: 3px solid transparent; }
    .side-link:hover { background: var(--navy-light); color: #fff; }
    .side-link.active { background: var(--navy-light); color: #fff; border-left-color: var(--accent); }
    .side-icon { width: 22px; height: 22px; display: flex; align-items: center; justify-content: center; }
    .side-icon svg { width: 20px; height: 20px; }
    .main-content { flex: 1; padding: 28px 32px; overflow: auto; }
    .container { max-width: 1200px; margin: 0 auto; }
    h2 { margin: 0 0 8px; font-size: 1.5rem; font-weight: 600; letter-spacing: -0.02em; }
    .muted { color: var(--text-muted); font-size: 0.875rem; margin-bottom: 24px; }
    .card { background: var(--surface); border: 1px solid var(--border); border-radius: var(--radius); padding: 24px; margin-bottom: 24px; box-shadow: var(--shadow); }
    .stat-row { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; margin-bottom: 28px; }
    .stat-card { border-radius: var(--radius); padding: 22px; color: #fff; box-shadow: var(--shadow); }
    .stat-card.blue { background: var(--card-blue); }
    .stat-card.purple { background: var(--card-purple); }
    .stat-card.green { background: var(--card-green); }
    .stat-card.orange { background: var(--card-orange); }
    .stat-card .icon-wrap { width: 44px; height: 44px; background: rgba(255,255,255,.2); border-radius: var(--radius-sm); display: flex; align-items: center; justify-content: center; margin-bottom: 12px; }
    .stat-card .icon-wrap svg { width: 24px; height: 24px; }
    .stat-card .num { font-size: 1.75rem; font-weight: 700; letter-spacing: -0.02em; }
    .stat-card .label { font-size: 0.8125rem; opacity: .9; margin-top: 4px; }
    .two-col { display: grid; grid-template-columns: 1fr 1fr; gap: 24px; margin-bottom: 24px; }
    .panel-title { font-size: 1rem; font-weight: 600; margin: 0 0 16px; display: flex; justify-content: space-between; align-items: center; }
    .panel-title a { font-size: 0.8125rem; font-weight: 500; }
    .list-row { padding: 12px 0; border-bottom: 1px solid var(--border); display: flex; align-items: center; gap: 12px; font-size: 0.875rem; }
    .list-row:last-child { border-bottom: none; }
    .avatar { width: 36px; height: 36px; border-radius: 50%; background: var(--accent); color: #fff; display: flex; align-items: center; justify-content: center; font-weight: 600; font-size: 0.875rem; flex-shrink: 0; }
    table { width: 100%; border-collapse: collapse; background: var(--surface); border-radius: var(--radius); overflow: hidden; border: 1px solid var(--border); box-shadow: var(--shadow); }
    th, td { padding: 14px 18px; text-align: left; font-size: 0.875rem; border-bottom: 1px solid var(--border); }
    th { background: var(--surface-hover); font-weight: 600; color: var(--text-muted); }
    tr:last-child td { border-bottom: none; }
    tr:hover td { background: var(--surface-hover); }
    .filters { margin-bottom: 20px; }
    .filters select { margin-right: 12px; }
    input, select { padding: 10px 14px; font-size: 0.875rem; border-radius: var(--radius-sm); border: 1px solid var(--border); background: var(--input-bg); color: var(--text); font-family: inherit; }
    input:focus, select:focus { outline: none; border-color: var(--accent); }
    input::placeholder { color: var(--text-muted); }
    label { margin-right: 12px; font-size: 0.875rem; color: var(--text-muted); }
    button { padding: 10px 20px; font-size: 0.875rem; font-weight: 600; cursor: pointer; border: none; border-radius: var(--radius-sm); background: var(--accent); color: #fff; font-family: inherit; transition: background .15s; }
    button:hover { background: var(--accent-hover); }
    .form-row { display: flex; flex-wrap: wrap; align-items: center; gap: 12px; margin-bottom: 12px; }
    .form-row label { display: flex; align-items: center; gap: 8px; margin-right: 0; }
    a { color: var(--accent); text-decoration: none; }
    a:hover { text-decoration: underline; }
    .chart-placeholder { height: 200px; background: var(--surface-hover); border-radius: var(--radius); display: flex; align-items: center; justify-content: center; color: var(--text-muted); font-size: 0.875rem; }
    .notification-row { padding: 12px 0; border-bottom: 1px solid var(--border); display: flex; align-items: flex-start; gap: 12px; font-size: 0.875rem; }
    .notification-row:last-child { border-bottom: none; }
    .notification-badge { font-size: 0.75rem; font-weight: 600; padding: 4px 10px; border-radius: 6px; flex-shrink: 0; }
    .notification-badge.new_user { background: #d1fae5; color: #065f46; }
    .notification-badge.subscription_start { background: #e9d5ff; color: #5b21b6; }
    .notification-badge.subscription_end { background: #fed7aa; color: #9a3412; }
    .notification-badge.billing_issue { background: #fecaca; color: #b91c1c; }
    .notification-badge.info { background: #dbeafe; color: #1e40af; }
    .notification-time { color: var(--text-muted); font-size: 0.8125rem; white-space: nowrap; }
    @media (max-width: 900px) { .stat-row { grid-template-columns: repeat(2, 1fr); } .two-col { grid-template-columns: 1fr; } }
    @media (max-width: 600px) { .stat-row { grid-template-columns: 1fr; } .sidebar { width: 72px; } .side-link span:not(.side-icon) { display: none; } }
  </style>
</head>
<body>
  <div class="app-wrap">
    <aside class="sidebar">${sidebarNav}</aside>
    <div style="flex:1; display:flex; flex-direction:column; min-width:0;">
      <header class="topbar">
        <div class="topbar-logo"><span>L</span> Lingola Admin</div>
        <div class="topbar-user">Admin</div>
      </header>
      <main class="main-content">
        <div class="container">${content}</div>
      </main>
    </div>
  </div>
</body>
</html>`;
}

router.get("/", async (req, res) => {
  try {
    const [
      { rows: langCount },
      { rows: trackCount },
      { rows: wordCount },
      { rows: userCount },
      { rows: recentTracks },
      { rows: latestUsers },
    ] = await Promise.all([
      pool.query("SELECT COUNT(*)::int AS c FROM languages"),
      pool.query("SELECT COUNT(*)::int AS c FROM learning_tracks"),
      pool.query("SELECT COUNT(*)::int AS c FROM words"),
      pool.query("SELECT COUNT(*)::int AS c FROM users"),
      pool.query("SELECT id, title, language_code, created_at FROM learning_tracks ORDER BY created_at DESC LIMIT 5"),
      pool.query("SELECT id, first_name, last_name, email, created_at FROM users ORDER BY created_at DESC LIMIT 5"),
    ]);

    let notifications = [];
    try {
      const notifResult = await pool.query(
        "SELECT id, type, title, message, created_at FROM admin_notifications ORDER BY created_at DESC LIMIT 25"
      );
      notifications = notifResult.rows;
    } catch (_) {
      /* admin_notifications tablosu yoksa (migration henüz çalışmadıysa) boş bırak */
    }

    const notificationBadgeClass = (type) => {
      if (type === "new_user") return "new_user";
      if (type === "subscription_start") return "subscription_start";
      if (type === "subscription_end" || type === "subscription_cancel") return "subscription_end";
      if (type === "billing_issue") return "billing_issue";
      return "info";
    };
    const notificationLabel = (type) => {
      const labels = { new_user: "Yeni üye", subscription_start: "Abonelik", subscription_end: "Bitiş", billing_issue: "Fatura" };
      return labels[type] || type;
    };
    const notificationsHtml = notifications.length
      ? notifications.map((n) => {
          const timeStr = new Date(n.created_at).toLocaleString("tr-TR");
          const badge = notificationBadgeClass(n.type);
          const label = notificationLabel(n.type);
          return `<div class="notification-row">
            <span class="notification-badge ${badge}">${escapeHtml(label)}</span>
            <div style="flex:1;">
              <div>${escapeHtml(n.title)}</div>
              ${n.message ? `<div class="muted" style="font-size:0.8125rem; margin-top:2px;">${escapeHtml(n.message)}</div>` : ""}
            </div>
            <span class="notification-time">${escapeHtml(timeStr)}</span>
          </div>`;
        }).join("")
      : "<div class=\"list-row muted\">Henüz bildirim yok.</div>";

    const tracksHtml = recentTracks.length
      ? recentTracks.map((t) => `<div class="list-row"><strong>${escapeHtml(t.title)}</strong><span class="muted">${escapeHtml(t.language_code)}</span><span class="muted">${new Date(t.created_at).toLocaleDateString("tr-TR")}</span></div>`).join("")
      : "<div class=\"list-row muted\">Henüz track yok.</div>";
    const usersHtml = latestUsers.length
      ? latestUsers.map((u) => {
          const name = [u.first_name, u.last_name].filter(Boolean).join(" ") || "—";
          const initial = (u.first_name || "?")[0].toUpperCase();
          return `<div class="list-row"><div class="avatar">${initial}</div><div><div>${escapeHtml(name)}</div><div class="muted" style="font-size:0.8125rem">${escapeHtml(u.email || "")}</div></div></div>`;
        }).join("")
      : "<div class=\"list-row muted\">Henüz kullanıcı yok.</div>";

    const html = layout(
      "Dashboard",
      `
      <h2>Dashboard</h2>
      <p class="muted">Genel özet.</p>
      <div class="stat-row">
        <div class="stat-card blue">
          <div class="icon-wrap"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3.055 11H5a2 2 0 012 2v1a2 2 0 002 2 2 2 0 012 2v2.945M8 3.935V5.5A2.5 2.5 0 0010.5 8h.5a2 2 0 012 2 2 2 0 104 0h.5a2.5 2.5 0 002.5-2.5V8"/></svg></div>
          <div class="num">${langCount[0].c}</div>
          <div class="label">Active Languages</div>
        </div>
        <div class="stat-card purple">
          <div class="icon-wrap"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 21v-4m0 0V5a2 2 0 012-2h6.5L17 8.5M3 17l4-4m0 0l4 4m-4-4v4"/></svg></div>
          <div class="num">${trackCount[0].c}</div>
          <div class="label">Total Tracks</div>
        </div>
        <div class="stat-card green">
          <div class="icon-wrap"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253"/></svg></div>
          <div class="num">${wordCount[0].c}</div>
          <div class="label">Total Words</div>
        </div>
        <div class="stat-card orange">
          <div class="icon-wrap"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/></svg></div>
          <div class="num">${userCount[0].c}</div>
          <div class="label">Total Users</div>
        </div>
      </div>
      <div class="card">
        <div class="panel-title">Bildirimler</div>
        ${notificationsHtml}
      </div>
      <div class="two-col">
        <div class="card">
          <div class="panel-title">Recent Tracks <a href="/admin/tracks">View All &rarr;</a></div>
          ${tracksHtml}
        </div>
        <div class="card">
          <div class="panel-title">Latest Users <a href="/admin/users">View All &rarr;</a></div>
          ${usersHtml}
        </div>
      </div>
      <div class="two-col">
        <div class="card">
          <div class="panel-title">Word Activity</div>
          <div class="chart-placeholder">Son 7 gün verisi (grafik alanı)</div>
        </div>
        <div class="card">
          <div class="panel-title">User Progress</div>
          <div class="chart-placeholder">İlerleme özeti (grafik alanı)</div>
        </div>
      </div>
      `,
      "/admin"
    );
    res.send(html);
  } catch (err) {
    console.error("Admin dashboard error:", err);
    res.status(500).send("Admin dashboard error");
  }
});

function escapeHtml(s) {
  if (s == null) return "";
  const t = String(s);
  return t.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");
}

router.get("/languages", async (req, res) => {
  try {
    const { rows } = await pool.query(
      "SELECT code, name FROM languages ORDER BY code"
    );
    const rowsHtml = rows
      .map(
        (l) => `<tr><td>${l.code}</td><td>${l.name}</td></tr>`
      )
      .join("");
    const html = layout(
      "Languages",
      `
      <h2>Languages</h2>
      <p class="muted">Yeni dil ekleyebilir veya var olan kodu yeniden kullanarak adını güncelleyebilirsin.</p>
      <div class="card">
        <form method="post" action="/admin/languages/create">
          <div class="form-row">
            <label>Code: <input name="code" required placeholder="english" /></label>
            <label>Name: <input name="name" required placeholder="English" /></label>
            <label>Native name: <input name="native_name" placeholder="English" /></label>
            <button type="submit">Kaydet</button>
          </div>
        </form>
      </div>
      <table>
        <thead><tr><th>Code</th><th>Name</th></tr></thead>
        <tbody>${rowsHtml}</tbody>
      </table>
      `,
      "/admin/languages"
    );
    res.send(html);
  } catch (err) {
    console.error("Admin languages error:", err);
    res.status(500).send("Admin languages error");
  }
});

router.post("/languages/create", async (req, res) => {
  try {
    const { code, name, native_name } = req.body;
    if (!code || !name) {
      return res.status(400).send("Code ve name zorunlu.");
    }
    const trimmedCode = String(code).trim();
    const trimmedName = String(name).trim();
    const trimmedNative =
      native_name && String(native_name).trim().length > 0
        ? String(native_name).trim()
        : trimmedName;

    await pool.query(
      `INSERT INTO languages (code, name, native_name)
       VALUES ($1, $2, $3)
       ON CONFLICT (code) DO UPDATE SET
         name = EXCLUDED.name,
         native_name = EXCLUDED.native_name`,
      [trimmedCode, trimmedName, trimmedNative]
    );

    res.redirect("/admin/languages");
  } catch (err) {
    console.error("Admin languages create error:", err);
    res.status(500).send("Admin languages create error");
  }
});

router.get("/tracks", async (req, res) => {
  const { language_code } = req.query;
  try {
    const where = language_code ? "WHERE lt.language_code = $1" : "";
    const params = language_code ? [language_code] : [];
    const { rows } = await pool.query(
      `SELECT lt.id, lt.language_code, lt.title, lt.level, lt.sort_order
       FROM learning_tracks lt
       ${where}
       ORDER BY lt.language_code, lt.sort_order, lt.id`,
      params
    );

    const options = rows
      .map(
        (t) => `<option value="${t.language_code}" ${
          language_code === t.language_code ? "selected" : ""
        }>${t.language_code}</option>`
      )
      .filter((v, i, a) => a.indexOf(v) === i)
      .join("");

    const rowsHtml = rows
      .map(
        (t) =>
          `<tr>
            <td>${t.id}</td>
            <td>${t.language_code}</td>
            <td>${t.title}</td>
            <td>${t.level || ""}</td>
            <td>${t.sort_order}</td>
          </tr>`
      )
      .join("");

    const html = layout(
      "Tracks",
      `
      <h2>Learning Tracks</h2>
      <div class="filters">
        <form method="get">
          <label>Dil: <select name="language_code" onchange="this.form.submit()"><option value="">(Hepsi)</option>${options}</select></label>
        </form>
      </div>
      <div class="card">
        <form method="post" action="/admin/tracks/create">
          <div class="form-row">
            <label>Language: <input name="language_code" placeholder="english" required /></label>
            <label>Title: <input name="title" required placeholder="Beginner Track" /></label>
            <label>Level: <input name="level" placeholder="beginner" /></label>
            <label>Sort: <input name="sort_order" type="number" value="0" style="width:72px;" /></label>
            <button type="submit">Track ekle</button>
          </div>
          <div class="form-row" style="flex-direction:column; align-items:stretch;">
            <label>Description: <input name="description" placeholder="Açıklama (opsiyonel)" style="width:100%; max-width:400px;" /></label>
          </div>
        </form>
      </div>
      <table>
        <thead><tr><th>ID</th><th>Language</th><th>Title</th><th>Level</th><th>Sort</th></tr></thead>
        <tbody>${rowsHtml}</tbody>
      </table>
      `,
      "/admin/tracks"
    );
    res.send(html);
  } catch (err) {
    console.error("Admin tracks error:", err);
    res.status(500).send("Admin tracks error");
  }
});

router.post("/tracks/create", async (req, res) => {
  try {
    const { language_code, title, description, level, sort_order } = req.body;
    if (!language_code || !title) {
      return res.status(400).send("Language code ve title zorunlu.");
    }
    const sort = Number.isNaN(parseInt(sort_order, 10))
      ? 0
      : parseInt(sort_order, 10);

    await pool.query(
      `INSERT INTO learning_tracks (language_code, title, description, level, sort_order)
       VALUES ($1, $2, $3, $4, $5)`,
      [
        String(language_code).trim(),
        String(title).trim(),
        description || null,
        level || null,
        sort,
      ]
    );

    res.redirect("/admin/tracks");
  } catch (err) {
    console.error("Admin tracks create error:", err);
    res.status(500).send("Admin tracks create error");
  }
});

router.get("/words", async (req, res) => {
  const { track_id } = req.query;
  try {
    const where = track_id ? "WHERE w.learning_track_id = $1" : "";
    const params = track_id ? [track_id] : [];
    const [wordsResult, tracksResult] = await Promise.all([
      pool.query(
        `SELECT w.id, w.learning_track_id, w.word, w.translation, w.level, w.sort_order
         FROM words w
         ${where}
         ORDER BY w.learning_track_id, w.sort_order, w.id`,
        params
      ),
      pool.query(
        "SELECT id, language_code, title, level FROM learning_tracks ORDER BY language_code, sort_order, id"
      ),
    ]);
    const rows = wordsResult.rows;

    const filterOptions = rows
      .map(
        (w) =>
          `<option value="${w.learning_track_id}" ${
            String(track_id || "") === String(w.learning_track_id) ? "selected" : ""
          }>Track #${w.learning_track_id}</option>`
      )
      .filter((v, i, a) => a.indexOf(v) === i)
      .join("");

    const trackSelectOptions = tracksResult.rows
      .map(
        (t) =>
          `<option value="${t.id}" ${String(track_id || "") === String(t.id) ? "selected" : ""}>${t.id} – ${t.language_code} – ${t.title}</option>`
      )
      .join("");

    const rowsHtml = rows
      .map(
        (w) =>
          `<tr>
            <td>${w.id}</td>
            <td>${w.learning_track_id}</td>
            <td>${w.word}</td>
            <td>${w.translation || ""}</td>
            <td>${w.level || ""}</td>
            <td>${w.sort_order}</td>
          </tr>`
      )
      .join("");

    const html = layout(
      "Words",
      `
      <h2>Words</h2>
      <div class="filters">
        <form method="get">
          <label>Track: <select name="track_id" onchange="this.form.submit()"><option value="">(Hepsi)</option>${filterOptions}</select></label>
        </form>
      </div>
      <div class="card">
        <form method="post" action="/admin/words/create">
          <div class="form-row">
            <label>Track: <select name="learning_track_id" required><option value="">— Seçin —</option>${trackSelectOptions}</select></label>
            <label>Word: <input name="word" required placeholder="hello" /></label>
            <label>Translation: <input name="translation" placeholder="merhaba" /></label>
            <label>Level: <input name="level" placeholder="A1" style="width:64px;" /></label>
            <label>Sort: <input name="sort_order" type="number" value="0" style="width:64px;" /></label>
            <button type="submit">Kelime ekle</button>
          </div>
        </form>
      </div>
      <table>
        <thead><tr><th>ID</th><th>Track ID</th><th>Word</th><th>Translation</th><th>Level</th><th>Sort</th></tr></thead>
        <tbody>${rowsHtml}</tbody>
      </table>
      `,
      "/admin/words"
    );
    res.send(html);
  } catch (err) {
    console.error("Admin words error:", err);
    res.status(500).send("Admin words error");
  }
});

router.post("/words/create", async (req, res) => {
  try {
    const { learning_track_id, word, translation, level, sort_order } = req.body;
    if (!learning_track_id || !word || String(word).trim() === "") {
      return res.status(400).send("Track ID ve Word zorunlu.");
    }
    const trackId = parseInt(learning_track_id, 10);
    if (Number.isNaN(trackId) || trackId < 1) {
      return res.status(400).send("Geçersiz Track ID. Sayı olmalı (örn. 7).");
    }
    const sort = Number.isNaN(parseInt(sort_order, 10))
      ? 0
      : parseInt(sort_order, 10);
    const wordTrimmed = String(word).trim();

    await pool.query(
      `INSERT INTO words (learning_track_id, word, translation, level, sort_order)
       VALUES ($1, $2, $3, $4, $5)
       ON CONFLICT (learning_track_id, word) DO NOTHING`,
      [trackId, wordTrimmed, translation && String(translation).trim() || null, level && String(level).trim() || null, sort]
    );

    res.redirect("/admin/words?track_id=" + trackId);
  } catch (err) {
    console.error("Admin words create error:", err.message || err, "code:", err.code);
    if (err.code === "23503") {
      return res.status(400).send("Bu Track ID veritabanında yok. Önce <a href=\"/admin/tracks\">Tracks</a> sayfasından geçerli bir track ID kullan (tablodaki ID sütunu).");
    }
    if (err.code === "23505") {
      return res.status(400).send("Bu track içinde aynı kelime zaten var. Farklı bir kelime yazın.");
    }
    res.status(500).send("Kelime eklenirken hata: " + (err.message || "Bilinmeyen hata"));
  }
});

router.get("/users", async (req, res) => {
  try {
    const { rows } = await pool.query(
      `SELECT u.id, u.firebase_uid, u.email, u.first_name, u.last_name, u.created_at
       FROM users u
       ORDER BY u.id`
    );

    const rowsHtml = rows
      .map(
        (u) =>
          `<tr>
            <td>${u.id}</td>
            <td>${u.email || ""}</td>
            <td>${u.first_name || ""} ${u.last_name || ""}</td>
            <td><span class="muted">${u.firebase_uid}</span></td>
            <td>${new Date(u.created_at).toLocaleString()}</td>
          </tr>`
      )
      .join("");

    const html = layout(
      "Users",
      `
      <h2>Users</h2>
      <table>
        <thead><tr><th>ID</th><th>Email</th><th>Name</th><th>Firebase UID</th><th>Created</th></tr></thead>
        <tbody>${rowsHtml}</tbody>
      </table>
      `,
      "/admin/users"
    );
    res.send(html);
  } catch (err) {
    console.error("Admin users error:", err);
    res.status(500).send("Admin users error");
  }
});

module.exports = router;

