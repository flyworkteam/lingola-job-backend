const {
  success,
  error,
  validationError,
  notFound,
  unauthorized,
  serverError,
} = require("../../lib/response");

describe("lib/response", () => {
  let res;
  let jsonMock;
  let statusMock;

  beforeEach(() => {
    jsonMock = jest.fn();
    statusMock = jest.fn().mockReturnValue({ json: jsonMock });
    res = { status: statusMock, json: jsonMock };
  });

  describe("success", () => {
    it("sends 200 and { success: true, data } by default", () => {
      success(res, { foo: "bar" });
      expect(statusMock).toHaveBeenCalledWith(200);
      expect(jsonMock).toHaveBeenCalledWith({ success: true, data: { foo: "bar" } });
    });
    it("accepts custom status", () => {
      success(res, { id: 1 }, 201);
      expect(statusMock).toHaveBeenCalledWith(201);
      expect(jsonMock).toHaveBeenCalledWith({ success: true, data: { id: 1 } });
    });
  });

  describe("error", () => {
    it("sends status and { success: false, error: { code, message } }", () => {
      error(res, "BAD_REQUEST", "Geçersiz", null, 400);
      expect(statusMock).toHaveBeenCalledWith(400);
      expect(jsonMock).toHaveBeenCalledWith({
        success: false,
        error: { code: "BAD_REQUEST", message: "Geçersiz" },
      });
    });
    it("includes details when provided", () => {
      error(res, "ERR", "Msg", [{ field: "x" }], 400);
      expect(jsonMock).toHaveBeenCalledWith({
        success: false,
        error: { code: "ERR", message: "Msg", details: [{ field: "x" }] },
      });
    });
  });

  describe("validationError", () => {
    it("sends 400 with VALIDATION_ERROR when code not given", () => {
      validationError(res, null, "Geçersiz istek");
      expect(statusMock).toHaveBeenCalledWith(400);
      expect(jsonMock).toHaveBeenCalledWith({
        success: false,
        error: { code: "VALIDATION_ERROR", message: "Geçersiz istek" },
      });
    });
  });

  describe("notFound", () => {
    it("sends 404 with NOT_FOUND by default", () => {
      notFound(res);
      expect(statusMock).toHaveBeenCalledWith(404);
      expect(jsonMock).toHaveBeenCalledWith({
        success: false,
        error: { code: "NOT_FOUND", message: "Kayıt bulunamadı" },
      });
    });
  });

  describe("unauthorized", () => {
    it("sends 401 with UNAUTHORIZED by default", () => {
      unauthorized(res);
      expect(statusMock).toHaveBeenCalledWith(401);
      expect(jsonMock).toHaveBeenCalledWith({
        success: false,
        error: { code: "UNAUTHORIZED", message: "Yetkisiz" },
      });
    });
  });

  describe("serverError", () => {
    it("sends 500 with SERVER_ERROR", () => {
      const err = new Error("DB down");
      serverError(res, err, "Sunucu hatası");
      expect(statusMock).toHaveBeenCalledWith(500);
      expect(jsonMock).toHaveBeenCalledWith({
        success: false,
        error: { code: "SERVER_ERROR", message: "Sunucu hatası" },
      });
    });
  });
});
