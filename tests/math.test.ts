import { describe, expect, it } from "vitest";
import { add } from "../src/math";

describe("math", () => {
  it("BasicAddition", () => {
    expect(add(2, 3)).toBe(5);
  });
});
