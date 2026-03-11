const { validate } = require("../../lib/validate");

describe("lib/validate", () => {
  let req;
  let res;
  let next;

  beforeEach(() => {
    req = { body: {}, query: {} };
    res = { status: jest.fn().mockReturnThis(), json: jest.fn() };
    next = jest.fn();
  });

  it("calls next() when body is valid for positive_number and boolean", () => {
    req.body = { word_id: 5, is_correct: true };
    const middleware = validate({ word_id: "positive_number", is_correct: "boolean" });
    middleware(req, res, next);
    expect(next).toHaveBeenCalled();
    expect(res.status).not.toHaveBeenCalled();
  });

  it("returns 400 with details when word_id is invalid", () => {
    req.body = { word_id: 0, is_correct: true };
    const middleware = validate({ word_id: "positive_number", is_correct: "boolean" });
    middleware(req, res, next);
    expect(next).not.toHaveBeenCalled();
    expect(res.status).toHaveBeenCalledWith(400);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({
        success: false,
        error: expect.objectContaining({
          code: "VALIDATION_ERROR",
          message: "Geçersiz istek",
          details: expect.any(Array),
        }),
      })
    );
  });

  it("returns 400 when required_string is empty", () => {
    req.body = { name: "  " };
    const middleware = validate({ name: "required_string" });
    middleware(req, res, next);
    expect(next).not.toHaveBeenCalled();
    expect(res.status).toHaveBeenCalledWith(400);
  });

  it("validates query when source is query", () => {
    req.query = { learning_track_id: "7" };
    const middleware = validate({ learning_track_id: "positive_number" }, "query");
    middleware(req, res, next);
    expect(next).toHaveBeenCalled();
  });
});
