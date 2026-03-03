const express = require("express");
const pool = require("../config/db");

const router = express.Router();

function layout(title, content) {
  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>${title}</title>
  <style>
    body { font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif; margin: 0; background:#f5f5f5; }
    header { background:#111827; color:#fff; padding:16px 24px; }
    header h1 { margin:0; font-size:20px; }
    nav a { color:#e5e7eb; margin-right:12px; text-decoration:none; font-size:14px; }
    nav a:hover { text-decoration:underline; }
    main { padding:24px; }
    h2 { margin-top:0; }
    table { border-collapse: collapse; width:100%; background:#fff; }
    th, td { border:1px solid #e5e7eb; padding:8px 10px; text-align:left; font-size:14px; }
    th { background:#f9fafb; }
    tr:nth-child(even) { background:#f9fafb; }
    .badge { display:inline-block; padding:2px 6px; border-radius:4px; font-size:11px; background:#e5e7eb; }
    .muted { color:#6b7280; font-size:12px; }
    .container { max-width:1100px; margin:0 auto; }
    .filters { margin-bottom:16px; font-size:14px; }
    .filters form { display:inline-block; margin-right:12px; }
    input, select { padding:4px 6px; font-size:13px; }
    button { padding:4px 10px; font-size:13px; cursor:pointer; }
    a { color:#2563eb; }
  </style>
</head>
<body>
  <header>
    <div class="container">
      <h1>Lingola Admin</h1>
      <nav>
        <a href="/admin">Dashboard</a>
        <a href="/admin/languages">Languages</a>
        <a href="/admin/tracks">Tracks</a>
        <a href="/admin/words">Words</a>
        <a href="/admin/users">Users</a>
      </nav>
    </div>
  </header>
  <main>
    <div class="container">
      ${content}
    </div>
  </main>
</body>
</html>`;
}

router.get("/", async (req, res) => {
  try {
    const [{ rows: langCount }, { rows: trackCount }, { rows: wordCount }, { rows: userCount }] =
      await Promise.all([
        pool.query("SELECT COUNT(*)::int AS c FROM languages"),
        pool.query("SELECT COUNT(*)::int AS c FROM learning_tracks"),
        pool.query("SELECT COUNT(*)::int AS c FROM words"),
        pool.query("SELECT COUNT(*)::int AS c FROM users"),
      ]);

    const html = layout(
      "Dashboard",
      `
      <h2>Dashboard</h2>
      <p class="muted">Genel özet.</p>
      <ul>
        <li><strong>Languages:</strong> ${langCount[0].c}</li>
        <li><strong>Learning tracks:</strong> ${trackCount[0].c}</li>
        <li><strong>Words:</strong> ${wordCount[0].c}</li>
        <li><strong>Users:</strong> ${userCount[0].c}</li>
      </ul>
      `
    );
    res.send(html);
  } catch (err) {
    console.error("Admin dashboard error:", err);
    res.status(500).send("Admin dashboard error");
  }
});

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
      <form method="post" action="/admin/languages/create" style="margin-bottom:16px;">
        <label>Code: <input name="code" required /></label>
        <label>Name: <input name="name" required /></label>
        <label>Native name: <input name="native_name" /></label>
        <button type="submit">Kaydet</button>
      </form>
      <table>
        <thead><tr><th>Code</th><th>Name</th></tr></thead>
        <tbody>${rowsHtml}</tbody>
      </table>
      `
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
          <label>Dil: 
            <select name="language_code" onchange="this.form.submit()">
              <option value="">(Hepsi)</option>
              ${options}
            </select>
          </label>
        </form>
      </div>
      <form method="post" action="/admin/tracks/create" style="margin-bottom:16px;">
        <label>Language code: <input name="language_code" placeholder="english" required /></label>
        <label>Title: <input name="title" required /></label>
        <label>Level: <input name="level" placeholder="beginner / B1" /></label>
        <label>Sort: <input name="sort_order" type="number" value="0" /></label>
        <br />
        <label>Description:<br /><input name="description" style="width:100%;" /></label>
        <br />
        <button type="submit">Track ekle</button>
      </form>
      <table>
        <thead><tr><th>ID</th><th>Language</th><th>Title</th><th>Level</th><th>Sort</th></tr></thead>
        <tbody>${rowsHtml}</tbody>
      </table>
      `
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
          <label>Track: 
            <select name="track_id" onchange="this.form.submit()">
              <option value="">(Hepsi)</option>
              ${filterOptions}
            </select>
          </label>
        </form>
      </div>
      <form method="post" action="/admin/words/create" style="margin-bottom:16px;">
        <label>Track: 
          <select name="learning_track_id" required>
            <option value="">— Seçin —</option>
            ${trackSelectOptions}
          </select>
        </label>
        <label>Word: <input name="word" required /></label>
        <label>Translation: <input name="translation" /></label>
        <label>Level: <input name="level" placeholder="A1 / B1 / C1" /></label>
        <label>Sort: <input name="sort_order" type="number" value="0" /></label>
        <button type="submit">Kelime ekle</button>
      </form>
      <table>
        <thead><tr><th>ID</th><th>Track ID</th><th>Word</th><th>Translation</th><th>Level</th><th>Sort</th></tr></thead>
        <tbody>${rowsHtml}</tbody>
      </table>
      `
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
      `
    );
    res.send(html);
  } catch (err) {
    console.error("Admin users error:", err);
    res.status(500).send("Admin users error");
  }
});

module.exports = router;

