const jestConfig = {
  // [...]
  preset: "ts-jest/presets/default-esm", // or other ESM presets
  //testRegex: "(/tests/.*|(\\.|/)(test|spec))\\.(jsx?|tsx?)$", // Match test files
  testMatch: ["<rootDir>/tests/**/*.test.ts"],
  moduleNameMapper: {
    "^(\\.{1,2}/.*)\\.js$": "$1",
  },
  transform: {
    // '^.+\\.[tj]sx?$' to process js/ts with `ts-jest`
    // '^.+\\.m?[tj]sx?$' to process js/ts/mjs/mts with `ts-jest`
    "^.+\\.tsx?$": [
      "ts-jest",
      {
        useESM: true,
        tsconfig: "<rootDir>/tests/tsconfig.test.json"
      },
    ],
  },
  moduleFileExtensions: ["js", "jsx", "ts", "tsx"],
  //testMatch: ["<rootDir>/tests/*.test.js"],
};

export default jestConfig;
