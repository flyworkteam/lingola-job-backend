const request = require("supertest");

jest.mock("../config/firebase.js", () => ({}));
jest.mock("../config/db", () => ({
  query: jest.fn(),
}));

const db = require("../config/db");

let app;
beforeAll(() => {
  app = require("../app");
});

beforeEach(() => {
  jest.clearAllMocks();
});

describe("API regresyon", () => {
  describe("GET /", () => {
    it("returns 200 ve backend mesajı", async () => {
      const res = await request(app).get("/");
      expect(res.status).toBe(200);
      expect(res.text).toContain("Backend");
    });
  });

  describe("GET /api/test", () => {
    it("returns 200 ve JSON message", async () => {
      const res = await request(app).get("/api/test");
      expect(res.status).toBe(200);
      expect(res.body).toEqual({ message: "API çalışıyor" });
    });
  });

  describe("GET /api/languages", () => {
    it("returns 200 ve success: true, data.languages array", async () => {
      db.query.mockResolvedValueOnce({ rows: [{ id: 1, code: "en", name: "English" }] });
      const res = await request(app).get("/api/languages");
      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(Array.isArray(res.body.data.languages)).toBe(true);
      expect(res.body.data.languages[0].code).toBe("en");
    });
  });

  describe("GET /api/words", () => {
    it("returns 200 ve success: true, data.words array", async () => {
      db.query.mockResolvedValueOnce({ rows: [{ id: 1, word: "hello", learning_track_id: 7 }] });
      const res = await request(app).get("/api/words");
      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(Array.isArray(res.body.data.words)).toBe(true);
    });
    it("returns 400 for invalid learning_track_id", async () => {
      const res = await request(app).get("/api/words?learning_track_id=invalid");
      expect(res.status).toBe(400);
      expect(res.body.success).toBe(false);
      expect(res.body.error.code).toBe("VALIDATION_ERROR");
    });
  });

  describe("GET /api/learning-tracks", () => {
    it("returns 200 ve success: true, data.tracks array", async () => {
      db.query.mockResolvedValueOnce({ rows: [{ id: 7, language_code: "english", title: "Beginner" }] });
      const res = await request(app).get("/api/learning-tracks");
      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(Array.isArray(res.body.data.tracks)).toBe(true);
    });
  });

  describe("POST /api/user-answers", () => {
    it("returns 401 without Authorization header", async () => {
      const res = await request(app)
        .post("/api/user-answers")
        .send({ word_id: 1, is_correct: true });
      expect(res.status).toBe(401);
      expect(res.body.success).toBe(false);
      expect(res.body.error).toHaveProperty("code");
    });
  });
});
